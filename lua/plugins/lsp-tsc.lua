return {
  -- Use the workspace TypeScript 7 LSP entrypoint patched by `effect-tsgo patch`.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local function project_roots(config)
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

        local deduped = {}
        local seen = {}
        for _, candidate in ipairs(candidates) do
          if candidate and candidate ~= "" and not seen[candidate] then
            seen[candidate] = true
            table.insert(deduped, candidate)
          end
        end
        return deduped
      end

      local function resolve_ts_lsp(config)
        for _, root in ipairs(project_roots(config)) do
          local tsc = vim.fs.joinpath(root, "node_modules", ".bin", "tsc")
          if vim.fn.executable(tsc) == 1 then
            return tsc
          end
        end

        return "tsc"
      end

      opts.servers = opts.servers or {}
      opts.servers.tsgo = vim.tbl_deep_extend("force", opts.servers.tsgo or {}, {
        mason = false,
        cmd = function(dispatchers, config)
          return vim.lsp.rpc.start({ resolve_ts_lsp(config), "--lsp", "--stdio" }, dispatchers)
        end,
      })
    end,
  },
}
