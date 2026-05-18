return {
  "selimacerbas/markdown-preview.nvim",
  dependencies = { "selimacerbas/live-server.nvim" },
  keys = {
    {
      "<leader>m",
      "<nop>",
      desc = "Markdown Preview"
    },
    {
      "<leader>ms",
      "<cmd>MarkdownPreview<cr>",
      desc = "Start markdown preview"
    },
    {
      "<leader>mr",
      "<cmd>MarkdownPreviewRefresh<cr>",
      desc = "Force refresh markdown preview"
    },
    {
      "<leader>mS",
      "<cmd>MarkdownPreviewStop<cr>",
      desc = "Stop markdown preview"
    },
  },
  config = function()
    require("markdown_preview").setup({
      -- all optional; sane defaults shown
      instance_mode = "takeover",  -- "takeover" (one tab) or "multi" (tab per instance)
      port = 0,                    -- 0 = auto (8421 for takeover, OS-assigned for multi)
      open_browser = true,
      debounce_ms = 300,
      mermaid_renderer = "rust",
    })

    -- Open preview in a new browser window instead of a new tab
    require("markdown_preview.util").open_in_browser = function(url)
      vim.fn.jobstart({ "google-chrome", "--new-window", url }, { detach = true })
    end
  end,
}
