-- File: lua/custom/plugins/autopairs.lua

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local lualine = require 'lualine'
    local config = {
      options = {
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
    }

    lualine.setup(config)
  end,
}
