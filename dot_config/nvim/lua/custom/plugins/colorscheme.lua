-- Colorscheme provides a theme for nvim.
--
return { -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`
  --
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha',
      transparent_background = true,
      integrations = {
        blink_cmp = true,
        cmp = true,
        flash = true,
        fzf = true,
        mini = {
          enabled = true,
          indentscope_color = "lavender",
        },
        noice = true,
        notify = true,
        snacks = {
          enabled = true,
          indent_scope_color = "lavender",
        },
        telescope = {
          enabled = true,
        },
        lsp_trouble = true,
        treesitter = true,
        which_key = true
      }
    }
    -- Load the colorscheme here
    vim.cmd.colorscheme 'catppuccin'

    -- You can configure highlights by doing something like
    vim.cmd.hi 'Comment gui=none'
  end,
}

-- Old themes
--
-- 'folke/tokyonight.nvim',
-- lazy = false, -- make sure we load this during startup if it is your main colorscheme
-- priority = 1000, -- make sure to load this before all the other start plugins
-- opts = {
--   transparent = true,
--   style = 'moon',
--   styles = {
--     sidebars = 'dark',
--     floats = 'dark',
--   },
-- },
