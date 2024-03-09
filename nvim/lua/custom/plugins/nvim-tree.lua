return {
  'nvim-tree/nvim-tree.lua',
  keys = {

    vim.keymap.set('n', '<leader>t', ':NvimTreeOpen<CR>', { desc = 'Toggle NvimTree' }),
  },
  config = function()
    require('nvim-tree').setup {}
  end,
}
