-- Snacks provides a collection of small plugins.
--
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    git = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true, style = "fancy" },
    notify = { enabled = true },
    statuscolumn = { enabled = true },
    toggle = { enabled = true },
  },
  keys = function()
    vim.keymap.set('', '<leader>sp', function() require("snacks").notifier.show_history() end, {desc="Search notifications"})
  end
}
