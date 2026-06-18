local M = {}

local cache_dir = vim.fn.stdpath("cache") .. "/markdown-pdf-preview"
local group = vim.api.nvim_create_augroup("MarkdownPdfPreview", { clear = true })
local states = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Markdown PDF Preview" })
end

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function source_path(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return nil
  end
  return vim.fn.fnamemodify(name, ":p")
end

local function state_for(buf)
  local state = states[buf]
  if state then
    return state
  end

  local src = source_path(buf)
  local basename = src and vim.fn.fnamemodify(src, ":t:r") or ("buffer-" .. buf)
  local hash = vim.fn.sha256(src or tostring(buf)):sub(1, 12)

  state = {
    buf = buf,
    page = 1,
    version = 0,
    basename = basename:gsub("[^%w_.-]+", "-"),
    hash = hash,
    enabled = false,
    running = false,
    pending = false,
    timer = nil,
    pdf_path = nil,
    preview_buf = nil,
    preview_win = nil,
  }
  states[buf] = state
  return state
end

local function close_timer(state)
  if state.timer then
    state.timer:stop()
    state.timer:close()
    state.timer = nil
  end
end

local function preview_valid(state)
  return state.preview_win
    and vim.api.nvim_win_is_valid(state.preview_win)
    and state.preview_buf
    and vim.api.nvim_buf_is_valid(state.preview_buf)
end

local function close_preview(state)
  close_timer(state)
  if state.preview_win and vim.api.nvim_win_is_valid(state.preview_win) then
    vim.api.nvim_win_close(state.preview_win, true)
  elseif state.preview_buf and vim.api.nvim_buf_is_valid(state.preview_buf) then
    vim.api.nvim_buf_delete(state.preview_buf, { force = true })
  end
  state.preview_win = nil
  state.preview_buf = nil
end

local function pdf_page_count(path)
  if not executable("pdfinfo") then
    return nil
  end
  local lines = vim.fn.systemlist({ "pdfinfo", path })
  for _, line in ipairs(lines) do
    local pages = line:match("^Pages:%s+(%d+)")
    if pages then
      return tonumber(pages)
    end
  end
  return nil
end

local function pdf_page_size(path, page)
  if not executable("pdfinfo") then
    return { width = 612, height = 792 }
  end
  local lines = vim.fn.systemlist({ "pdfinfo", "-f", tostring(page), "-l", tostring(page), path })
  for _, line in ipairs(lines) do
    local width, height = line:match("^Page%s+%d+%s+size:%s+([%d.]+)%s+x%s+([%d.]+)")
    if not width then
      width, height = line:match("^Page size:%s+([%d.]+)%s+x%s+([%d.]+)")
    end
    if width and height then
      return { width = tonumber(width), height = tonumber(height) }
    end
  end
  return { width = 612, height = 792 }
end

local function fit_width_cells(state)
  local win_width = state.preview_win and vim.api.nvim_win_is_valid(state.preview_win)
      and vim.api.nvim_win_get_width(state.preview_win)
    or 82
  local width = math.max(24, win_width - 2)
  local page = pdf_page_size(state.pdf_path, state.page)
  local terminal = Snacks.image.terminal.size()
  local height = math.ceil((width * terminal.cell_width) * (page.height / page.width) / terminal.cell_height)
  return width, math.max(1, height)
end

local function set_preview_lines(state, height)
  Snacks.image.placement.clean(state.preview_buf)
  vim.bo[state.preview_buf].modifiable = true
  local lines = {}
  for _ = 1, height do
    lines[#lines + 1] = " "
  end
  vim.api.nvim_buf_set_lines(state.preview_buf, 0, -1, false, lines)
  vim.bo[state.preview_buf].modifiable = false
  vim.bo[state.preview_buf].modified = false
end

local function open_split(state)
  if preview_valid(state) then
    return
  end

  local source_win = vim.api.nvim_get_current_win()
  state.preview_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.preview_buf].bufhidden = "wipe"
  vim.bo[state.preview_buf].swapfile = false

  vim.cmd("botright vertical 82new")
  state.preview_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.preview_win, state.preview_buf)
  vim.wo[state.preview_win].number = false
  vim.wo[state.preview_win].relativenumber = false
  vim.wo[state.preview_win].signcolumn = "no"
  vim.wo[state.preview_win].wrap = false
  vim.api.nvim_set_current_win(source_win)
end

local function render_pdf(state)
  if not state.enabled or not state.pdf_path then
    return
  end
  if vim.fn.filereadable(state.pdf_path) ~= 1 then
    return
  end

  local pages = pdf_page_count(state.pdf_path)
  if pages and state.page > pages then
    state.page = pages
  end
  if state.page < 1 then
    state.page = 1
  end

  open_split(state)
  local src = ("%s#page=%d"):format(state.pdf_path, state.page)
  if not Snacks.image.supports(state.pdf_path) then
    Snacks.image.buf.attach(state.preview_buf, { src = state.pdf_path })
    return
  end

  local width, height = fit_width_cells(state)
  set_preview_lines(state, height)
  vim.bo[state.preview_buf].filetype = "image"
  vim.bo[state.preview_buf].swapfile = false
  Snacks.image.placement.new(state.preview_buf, src, {
    pos = { 1, 1 },
    range = { 1, 1, height, 1 },
    width = width,
    height = height,
    conceal = true,
    auto_resize = true,
  })
end

local function pandoc_args(md_path, pdf_path, source_dir)
  return {
    "pandoc",
    md_path,
    "-o",
    pdf_path,
    "--pdf-engine=xelatex",
    "--resource-path=" .. source_dir,
    -- macOS-default fonts; change these if the fonts aren't available.
    "-V",
    "mainfont=Arial Unicode MS",
    "-V",
    "monofont=Menlo",
  }
end

local function build_pdf(state)
  if state.running then
    state.pending = true
    return
  end

  if not executable("pandoc") then
    notify("pandoc is not installed", vim.log.levels.ERROR)
    return
  end
  if not executable("xelatex") then
    notify("xelatex is not installed", vim.log.levels.ERROR)
    return
  end

  local buf = state.buf
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  vim.fn.mkdir(cache_dir, "p")
  state.version = state.version + 1

  local src = source_path(buf)
  local source_dir = src and vim.fn.fnamemodify(src, ":h") or vim.fn.getcwd()
  local stem = ("%s-%s-browser-v%d"):format(state.hash, state.basename, state.version)
  local md_path = ("%s/%s.md"):format(cache_dir, stem)
  local pdf_path = ("%s/%s.pdf"):format(cache_dir, stem)

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  vim.fn.writefile(lines, md_path)

  state.running = true
  state.pending = false

  vim.system(pandoc_args(md_path, pdf_path, source_dir), { cwd = source_dir, text = true }, function(result)
    vim.schedule(function()
      state.running = false
      if result.code == 0 and vim.fn.filereadable(pdf_path) == 1 then
        state.pdf_path = pdf_path
        render_pdf(state)
      else
        local err = vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
        notify(err ~= "" and err or "pandoc failed", vim.log.levels.ERROR)
      end

      if state.pending and state.enabled then
        build_pdf(state)
      end
    end)
  end)
end

local function schedule_build(state)
  if not state.enabled then
    return
  end
  close_timer(state)
  state.timer = vim.uv.new_timer()
  state.timer:start(900, 0, function()
    vim.schedule(function()
      close_timer(state)
      build_pdf(state)
    end)
  end)
end

local function attach_autocmds(state)
  vim.api.nvim_clear_autocmds({ group = group, buffer = state.buf })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
    group = group,
    buffer = state.buf,
    callback = function()
      schedule_build(state)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = state.buf,
    once = true,
    callback = function()
      M.close(state.buf)
      states[state.buf] = nil
    end,
  })

  state.resize_group = vim.api.nvim_create_augroup("MarkdownPdfPreviewResize" .. state.buf, { clear = true })
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = state.resize_group,
    callback = function()
      vim.schedule(function()
        if state.enabled and preview_valid(state) then
          render_pdf(state)
        end
      end)
    end,
  })
end

function M.open(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local state = state_for(buf)
  state.enabled = true
  attach_autocmds(state)
  build_pdf(state)
end

function M.close(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local state = states[buf]
  if not state then
    return
  end
  state.enabled = false
  state.pending = false
  vim.api.nvim_clear_autocmds({ group = group, buffer = buf })
  if state.resize_group then
    pcall(vim.api.nvim_clear_autocmds, { group = state.resize_group })
  end
  close_preview(state)
end

function M.toggle()
  local buf = vim.api.nvim_get_current_buf()
  local state = state_for(buf)
  if state.enabled then
    M.close(buf)
  else
    M.open(buf)
  end
end

function M.refresh()
  local state = state_for(vim.api.nvim_get_current_buf())
  state.enabled = true
  build_pdf(state)
end

function M.next_page()
  local state = state_for(vim.api.nvim_get_current_buf())
  if not state.pdf_path then
    return
  end
  local pages = pdf_page_count(state.pdf_path)
  if not pages or state.page < pages then
    state.page = state.page + 1
  end
  render_pdf(state)
end

function M.prev_page()
  local state = state_for(vim.api.nvim_get_current_buf())
  if not state.pdf_path then
    return
  end
  state.page = math.max(1, state.page - 1)
  render_pdf(state)
end

return M
