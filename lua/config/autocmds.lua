-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Add the project's node_modules/.bin to PATH so workspace-installed binaries
-- (tsgo, oxlint, etc.) are found without global installation.
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    local nm = vim.fn.finddir("node_modules", vim.fn.getcwd() .. ";")
    if nm == "" then return end
    local bin = vim.fn.fnamemodify(nm, ":p") .. ".bin"
    if not vim.env.PATH:find(bin, 1, true) then
      vim.env.PATH = bin .. ":" .. vim.env.PATH
    end
  end,
})
