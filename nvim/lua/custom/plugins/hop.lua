return {
  'smoka7/hop.nvim',
  version = '*',
  opts = {},
  lazy = false,
  keys = function()
    local hop = require 'hop'
    local directions = require('hop.hint').HintDirection

    -- search forward
    vim.keymap.set('', 'f', function()
      hop.hint_char1 { direction = directions.AFTER_CURSOR, current_line_only = false }
    end, { remap = true })

    -- search backward
    vim.keymap.set('', 'F', function()
      hop.hint_char1 { direction = directions.BEFORE_CURSOR, current_line_only = false }
    end, { remap = true })

    -- search forward (offset 1)
    vim.keymap.set('', 't', function()
      hop.hint_char1 { direction = directions.AFTER_CURSOR, current_line_only = false, hint_offset = -1 }
    end, { remap = true })

    -- search backward (offset 1)
    vim.keymap.set('', 'T', function()
      hop.hint_char1 { direction = directions.BEFORE_CURSOR, current_line_only = false, hint_offset = 1 }
    end, { remap = true })

    -- hop line
    vim.keymap.set('', '<leader>hl', function()
      hop.hint_lines {}
    end, { remap = true, desc = 'Hop to line' })

    -- hop line and skip whitespace
    vim.keymap.set('', '<leader>hs', function()
      hop.hint_lines_skip_whitespace {}
    end, { remap = true, desc = 'Hop to line start' })

    -- hop pattern
    vim.keymap.set('', '<leader>hp', function()
      hop.hint_patterns {}
    end, { remap = true, desc = 'Hop to pattern' })

    -- hop word
    vim.keymap.set('', '<leader>hw', function()
      hop.hint_words {}
    end, { remap = true, desc = 'Hop to word' })

    -- hop vertical
    vim.keymap.set('', '<leader>hv', function()
      hop.hint_patterns {}
    end, { remap = true, desc = 'Hop to vertical position' })
  end,
}
