return {
  -- The `lang.typescript.tsgo` extra (enabled in lazyvim.json) selects tsgo as
  -- the TS server. It assumes mason provides the binary, but we want the
  -- workspace's node_modules/.bin/tsgo (resolved by nvim-lspconfig's shipped
  -- lsp/tsgo.lua cmd). Setting mason = false makes LazyVim enable tsgo directly
  -- via vim.lsp.enable instead of waiting on mason. Merge so we don't clobber
  -- the extra's settings or formatting.lua's on_attach.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.tsgo = vim.tbl_deep_extend("force", opts.servers.tsgo or {}, {
        mason = false,
      })
    end,
  },
}
