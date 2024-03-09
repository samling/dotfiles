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
      ['<leader>'] = {
        q = {
          name = '[q] Quit/session',
        },
        h = {
          name = '[h] Hop',
        },
        s = {
          name = '[s] Search with Telescope',
        },
      },
    }
  end,
}
