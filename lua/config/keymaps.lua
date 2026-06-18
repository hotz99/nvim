-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- -- File: ~/.config/nvim/lua/config/keymaps.lua (or similar location)

-- Bind 'jj' to <Esc> in Insert Mode
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Escape with jj" })

vim.keymap.set("n", "<leader>at", function()
  local file_path = vim.fn.expand("%:.")
  local line_num = vim.fn.line(".")
  local col_num = vim.fn.col(".")
  -- Format: @{path} L{line}:C{col}
  local s = string.format("@%s L%d:C%d", file_path, line_num, col_num)
  vim.fn.setreg("+", s)
  vim.notify("Yanked: " .. s)
end, { desc = "Yank path:L:C" })

vim.keymap.set("n", "<leader>af", function()
  -- Format: @{path} (just the path, still relative)
  local s = string.format("@%s", vim.fn.expand("%:."))
  vim.fn.setreg("+", s)
  vim.notify("Yanked: " .. s)
end, { desc = "Yank rel path" })
