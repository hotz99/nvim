return {
  -- 1. Configure Conform to use oxfmt (matches the project's `bun run fmt`)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        -- conform has no built-in oxfmt; define it here.
        -- oxfmt reads from stdin via --stdin-filepath, which lets it resolve
        -- .oxfmtrc.json and infer the parser from the buffer's path.
        -- The nvim config injects workspace node_modules/.bin into PATH
        -- (DirChanged autocmd), so `oxfmt` resolves to the local binary in-repo.
        oxfmt = {
          command = "oxfmt",
          stdin = true,
          args = { "--stdin-filepath", "$FILENAME" },
          -- Only run inside an oxfmt project so unrelated files don't error.
          cwd = require("conform.util").root_file({ ".oxfmtrc.json", ".oxfmtrc", "oxfmt.json" }),
          require_cwd = true,
        },
      },
      formatters_by_ft = {
        javascript = { "oxfmt" },
        typescript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescriptreact = { "oxfmt" },
        -- No json/jsonc here on purpose: the monorepo's `oxfmt` runs over the
        -- whole tree but is JS/TS-focused, and oxfmt formats JSON in a
        -- divergent single-line JS-object style. Keeping format-on-save off for
        -- JSON avoids reintroducing a formatter that diverges from the repo.
      },
    },
  },

  -- 2. Disable LSP formatting for TS/JS to avoid conflicts with oxfmt
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.tsgo = vim.tbl_deep_extend("force", opts.servers.tsgo or {}, {
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      })
    end,
  },
}
