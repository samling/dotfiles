return {
  "f-person/git-blame.nvim",
  keys = {
    {
      "<leader>gb",
      "<cmd>GitBlameToggle<cr>",
      desc = "Toggle git blame",
    },
  },
  cmd = { "GitBlameToggle", "GitBlameEnable", "GitBlameDisable" },
  opts = {
    enabled = false,
  },
}
