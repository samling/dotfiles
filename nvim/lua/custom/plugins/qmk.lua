return {
  'codethread/qmk.nvim',
  config = function()
    ---@type qmk.UserConfig
    local conf = {
      name = 'LAYOUT_glove80',
      variant = 'zmk',
      layout = {
        'x x x x x _ _ _ _ _ _ _ _ x x x x x',
        'x x x x x x _ _ _ _ _ _ x x x x x x',
        'x x x x x x _ _ _ _ _ _ x x x x x x',
        'x x x x x x _ _ _ _ _ _ x x x x x x',
        'x x x x x x x x x x x x x x x x x x',
        'x x x x x _ x x x x x x _ x x x x x',
      },
    }
    require('qmk').setup(conf)
  end,
}
