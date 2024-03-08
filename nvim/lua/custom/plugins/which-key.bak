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
      plugins = { spelling = true },
      key_labels = { ['<leader>'] = 'SPC' },
    }
    wk.register {
      mode = { 'n', 'v' },
      ['g'] = { name = '+goto' },
      [']'] = { name = '+next' },
      ['['] = { name = '+prev' },
      ['<leader>b'] = { name = '+buffer' },
      ['<leader>q'] = { name = '+quit/session' },
      ['<leader>s'] = { name = '+search' },
      ['<leader>w'] = { name = '+windows' },
      ['<leader><tab>'] = { name = '+tabs' },
    }
  end,
}
