return {
  'smoka7/hop.nvim',
  version = '*',
  opts = {},
  lazy = false,
  keys = function()
    local hop = require 'hop'
    local directions = require('hop.hint').HintDirection
    vim.keymap.set('', 'f', function()
      hop.hint_char1 { direction = directions.AFTER_CURSOR, current_line_only = false }
    end, { remap = true })
    vim.keymap.set('', 'F', function()
      hop.hint_char1 { direction = directions.BEFORE_CURSOR, current_line_only = false }
    end, { remap = true })
    vim.keymap.set('', 't', function()
      hop.hint_char1 { direction = directions.AFTER_CURSOR, current_line_only = false, hint_offset = -1 }
    end, { remap = true })
    vim.keymap.set('', 'T', function()
      hop.hint_char1 { direction = directions.BEFORE_CURSOR, current_line_only = false, hint_offset = 1 }
    end, { remap = true })
    vim.keymap.set('', '<leader>hl', function()
      hop.hint_lines {}
    end, { remap = true })
    vim.keymap.set('', '<leader>hs', function()
      hop.hint_lines_skip_whitespace {}
    end, { remap = true })
    vim.keymap.set('', '<leader>hw', function()
      hop.hint_words {}
    end, { remap = true })
    vim.keymap.set('', '<leader>hp', function()
      hop.hint_patterns {}
    end, { remap = true })
  end,
}
