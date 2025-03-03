local wezterm = require('wezterm')

local config = {
  enable_wayland = false,
  animation_fps = 120,
  enable_tab_bar = false,
  font = wezterm.font('IosevkaTerm NFM'),
  font_size = 14,
  color_scheme = "Catppuccin Mocha",
  window_decorations = "RESIZE"
}

return config
