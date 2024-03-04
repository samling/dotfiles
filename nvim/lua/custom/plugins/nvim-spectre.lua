return {
  'nvim-pack/nvim-spectre',
  test = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('spectre').setup {
      live_update = true,
    }
  end,
}
