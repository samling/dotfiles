return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    mode = { 'n', 'v' },
  },
  config = function()
    local wk = require 'which-key'
    wk.setup {
      plugins = {
        spelling = true,
        presets = {
          operators = false,
        },
      },
      key_labels = { ['<leader>'] = 'SPC' },
    }
    wk.register {
      g = {
        name = '+goto',
      },
      ['['] = {
        name = '+prev',
      },
      [']'] = {
        name = '+next',
      },
      ['<leader>'] = {
        b = {
          name = '+buffers',
        },
        h = {
          mode = { 'n', 'v' },
          name = '+hop',
        },
        n = {
          name = '+noice',
        },
        q = {
          name = '+quit/session',
        },
        r = {
          mode = { 'n', 'v' },
          name = '+replace with spectre',
        },
        s = {
          name = '+search with telescope',
        },
      },
    }
  end,
}
