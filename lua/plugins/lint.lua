return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- --type-aware runs oxlint-tsgolint, so the editor sees the same rules the
      -- Claude Code feedback gate does (hooks/feedback/lint-pass.ts passes the
      -- same flag). Without it nvim silently reports strictly fewer findings than
      -- the agent. Costs ~0.15s per lint; nvim-lint runs on BufWritePost, not on
      -- keystroke, so this lands on save.
      linters = {
        oxlint = { args = { "--format", "github", "--type-aware" } },
      },
      linters_by_ft = {
        javascript = { "oxlint" },
        javascriptreact = { "oxlint" },
        typescript = { "oxlint" },
        typescriptreact = { "oxlint" },
      },
    },
  },
}
