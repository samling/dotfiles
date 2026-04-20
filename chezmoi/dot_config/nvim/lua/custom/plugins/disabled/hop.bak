return {
  'smoka7/hop.nvim',
  version = '*',
  opts = {},
  lazy = false,
  keys = function()
    local hop = require 'hop'

    -- hop line
    vim.keymap.set('', '<leader>l', function()
      hop.hint_lines {}
    end, { remap = true, desc = 'Hop to line' })

    -- hop pattern
    vim.keymap.set('', '<leader>f', function()
      hop.hint_patterns {}
    end, { remap = true, desc = 'Hop to pattern' })
  end,
}
