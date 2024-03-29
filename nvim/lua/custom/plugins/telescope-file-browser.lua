return {
  'nvim-telescope/telescope-file-browser.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  keys = {
    vim.keymap.set('n', '<space>sf', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', { noremap = true, desc = 'Search files' }),
  },
  config = function()
    require('telescope').setup {
      extensions = {
        hijack_netrw = true,
        file_browser = {
          mappings = {
            ['i'] = {
              ['<C-d>'] = false,
            },
            ['n'] = {
              d = false,
            },
          },
        },
      },
    }
    require('telescope').load_extension 'file_browser'
  end,
}
