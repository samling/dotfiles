return {
  -- add tokyonight theme
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = true,
    style = "night",
    styles = {
      sidebars = "dark",
      floats = "dark",
    },
    on_colors = function(colors)
      colors.hint = colors.orange
    end,
  },
}
