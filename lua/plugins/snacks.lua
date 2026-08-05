return {
  "folke/snacks.nvim",
  opts = {
    gitbrowse = {
      config = function(opts, defaults)
        opts.remote_patterns = vim.list_extend({
          { "^git@github%-work:(.+)%.git$", "https://github.com/%1" },
          { "^git@github%-work:(.+)$", "https://github.com/%1" },
          { "^git@github%-personal:(.+)%.git$", "https://github.com/%1" },
          { "^git@github%-personal:(.+)$", "https://github.com/%1" },
        }, vim.deepcopy(defaults.remote_patterns or {}))
      end,
    },
    image = {
      enabled = true,
      convert = {
        magick = {
          pdf = { "-density", 192, "{src}[{page}]", "-background", "white", "-alpha", "remove" },
        },
      },
    },
    picker = {
      sources = {
        explorer = {
          exclude = {
            "*.aux",
            "*.fdb_latexmk",
            "*.fls",
            "*.log",
            "*.out",
            "*.synctex.gz",
            "*.toc",
            "*.bbl",
            "*.bcf",
            "*.blg",
            "*.run.xml",
            "*.lof",
            "*.lot",
          },
        },
      },
    },
  },
}
