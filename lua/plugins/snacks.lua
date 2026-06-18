return {
  "folke/snacks.nvim",
  opts = {
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
