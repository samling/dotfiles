return {
  'RRethy/base16-nvim',
  lazy = false,
  config = function()
    require('base16-colorscheme').with_config({
      telescope = true,
      indentblankline = true,
      notify = true,
      ts_rainbow = true,
      cmp = true,
      illuminate = true,
      dapui = true,
    })

    local matugen_path = os.getenv("HOME") .. "/.config/nvim/generated.lua"
    local file = io.open(matugen_path, "r")
    if file then
      io.close(file)
      dofile(matugen_path)
    else
      vim.cmd('colorscheme base16-catppuccin-mocha')
    end
  end,
}
