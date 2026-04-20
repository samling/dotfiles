return {
  'nvim-pack/nvim-spectre',
  test = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('spectre').setup {
      live_update = true,
    }
  end,
  keys = {
    vim.keymap.set('v', '<leader>r', '', {
      desc = 'Replace with Spectre',
    }),
    vim.keymap.set('n', '<leader>ra', '<cmd>lua require("spectre").toggle()<CR>', {
      desc = 'Replace in all files',
    }),
    vim.keymap.set('n', '<leader>rw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
      desc = 'Replace current word',
    }),
    vim.keymap.set('v', '<leader>rv', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
      desc = 'Replace current visual selection',
    }),
    vim.keymap.set('n', '<leader>rf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
      desc = 'Replace in current file',
    }),
  },
}
