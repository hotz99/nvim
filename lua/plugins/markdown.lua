return {
  {
    "folke/snacks.nvim",
    init = function()
      vim.api.nvim_create_user_command("MarkdownPdfPreview", function()
        require("config.markdown_pdf_preview").toggle()
      end, {})
      vim.api.nvim_create_user_command("MarkdownPdfRefresh", function()
        require("config.markdown_pdf_preview").refresh()
      end, {})
      vim.api.nvim_create_user_command("MarkdownPdfNext", function()
        require("config.markdown_pdf_preview").next_page()
      end, {})
      vim.api.nvim_create_user_command("MarkdownPdfPrev", function()
        require("config.markdown_pdf_preview").prev_page()
      end, {})
    end,
    keys = {
      {
        "<leader>mp",
        function()
          require("config.markdown_pdf_preview").toggle()
        end,
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown PDF Preview",
      },
      {
        "<leader>mr",
        function()
          require("config.markdown_pdf_preview").refresh()
        end,
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown PDF Refresh",
      },
      {
        "<leader>m]",
        function()
          require("config.markdown_pdf_preview").next_page()
        end,
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown PDF Next Page",
      },
      {
        "<leader>m[",
        function()
          require("config.markdown_pdf_preview").prev_page()
        end,
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown PDF Previous Page",
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    keys = {
      {
        "<leader>mM",
        "<cmd>RenderMarkdown preview<cr>",
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown Text Preview",
      },
    },
  },
}
