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
    -- Load matugen color overrides if available, otherwise use stock mocha
    local overrides_path = os.getenv("HOME") .. "/.config/nvim/catppuccin-overrides.lua"
    local ok, overrides = pcall(dofile, overrides_path)

    require('catppuccin').setup {
      flavour = 'mocha',
      transparent_background = true,
      color_overrides = ok and { mocha = overrides } or {},
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
    vim.cmd.colorscheme 'catppuccin'
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
