return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesitter-context').setup {
      line_numbers = true,
      mode = 'topline',
    }

    function highlight(args)
      vim.cmd('highlight ' .. args)
    end
    highlight 'TreeSitterContextBottom gui=underline guisp=Grey'
  end,
}
