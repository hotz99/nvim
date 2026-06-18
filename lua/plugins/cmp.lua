return {
  "hrsh7th/nvim-cmp",
  init = function()
    vim.g.cmp_disabled = false -- default state: completion enabled
  end,
  opts = function(_, opts)
    -- Don't auto-open the completion menu; trigger it manually instead.
    opts.completion = { autocomplete = false }
    return opts
  end,
  keys = {
    {
      "<leader>uA",
      function()
        vim.g.cmp_disabled = not vim.g.cmp_disabled
        require("cmp").setup({
          enabled = function()
            return not vim.g.cmp_disabled
          end,
        })
        local msg = vim.g.cmp_disabled and "Autocompletion (cmp) disabled" or "Autocompletion (cmp) enabled"
        vim.notify(msg, vim.log.levels.INFO)
      end,
      desc = "Toggle autocompletion",
    },
  },
}
