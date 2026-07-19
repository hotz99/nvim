return {
  -- LazyVim and nvim-lspconfig still call the native TS LSP config `tsgo`,
  -- but TypeScript 7 exposes that server through `tsc --lsp --stdio`.
  -- Resolve the workspace/system `tsc` directly and do not fall back to the old
  -- `tsgo` binary. Setting mason = false makes LazyVim enable the server
  -- directly via vim.lsp.enable instead of waiting on mason. Merge so we don't
  -- clobber the extra's settings or formatting.lua's on_attach.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local function resolve_tsc(config)
        local candidates = {}

        if type(config.root_dir) == "string" and config.root_dir ~= "" then
          table.insert(candidates, config.root_dir)
        end

        local buf = vim.api.nvim_get_current_buf()
        local bufname = vim.api.nvim_buf_get_name(buf)
        if bufname ~= "" then
          local root = vim.fs.root(bufname, {
            "pnpm-lock.yaml",
            "package-lock.json",
            "yarn.lock",
            "bun.lock",
            "bun.lockb",
            ".git",
          })
          if root then
            table.insert(candidates, root)
          end
        end

        table.insert(candidates, vim.fn.getcwd())

        local seen = {}
        for _, candidate in ipairs(candidates) do
          if candidate and candidate ~= "" and not seen[candidate] then
            seen[candidate] = true
            local local_cmd = vim.fs.joinpath(candidate, "node_modules", ".bin", "tsc")
            if vim.fn.executable(local_cmd) == 1 then
              return local_cmd
            end
          end
        end

        return "tsc"
      end

      opts.servers = opts.servers or {}
      opts.servers.tsgo = vim.tbl_deep_extend("force", opts.servers.tsgo or {}, {
        mason = false,
        cmd = function(dispatchers, config)
          return vim.lsp.rpc.start({ resolve_tsc(config), "--lsp", "--stdio" }, dispatchers)
        end,
      })
    end,
  },
}
