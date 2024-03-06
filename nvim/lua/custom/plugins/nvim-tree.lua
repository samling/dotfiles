return {
  'nvim-tree/nvim-tree.lua',
  config = function()
    local function my_on_attach()
      local api = require 'nvim-tree.api'
    end

    require('nvim-tree').setup {
      on_attach = my_on_attach,
    }
  end,
}
