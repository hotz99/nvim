return {
  "lervag/vimtex",
  lazy = false,
  -- NOTE: macOS-specific. Uses Skim as the PDF viewer and focuses Ghostty
  -- (com.mitchellh.ghostty) on reverse-search via the macOS `open` command.
  -- Adjust the viewer/terminal if you run this elsewhere.
  init = function()
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 1
    vim.api.nvim_create_autocmd("User", {
      pattern = "VimtexEventViewReverse",
      callback = function()
        vim.fn.jobstart({ "open", "-b", "com.mitchellh.ghostty" }, { detach = true })
      end,
    })
    vim.g.vimtex_compiler_latexmk = {
      callback = 1,
      continuous = 1,
      executable = "latexmk",
      options = {
        "-pdf",
        "-shell-escape",
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }
  end,
}
