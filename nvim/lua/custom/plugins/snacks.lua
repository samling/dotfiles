return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    animate = { enabled = true },
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    debug = { enabled = true },
    git = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    layout = { enabled = true },
    notifier = { enabled = true },
    notify = { enabled = true },
    profiler = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    toggle = { enabled = true },
    util = { enabled = true },
  },
  keys = function()
    vim.keymap.set('', '<leader>sp', function() require("snacks").notifier.show_history() end, {desc="Search notifications"})
  end
}
