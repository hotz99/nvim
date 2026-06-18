return {
  "kdheepak/lazygit.nvim",
  -- optional: if you want to set up a keymap for LazyGit
  keys = {
    {
      "<leader>gg",
      "<cmd>LazyGit<cr>",
      desc = "LazyGit (Floating Window)",
    },
  },
  -- lazygit.nvim has no setup() function; configure via vim.g.* globals instead.
  -- e.g. vim.g.lazygit_floating_window_border = "single"
}
