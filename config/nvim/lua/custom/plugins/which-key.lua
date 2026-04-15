-- Provides a pop-up with a map of configured keybindings.
--
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    win = {
      border = 'rounded',
    },
    icons = {
      separator = "",
      group = "",
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
