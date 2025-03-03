local wezterm = require('wezterm')

local config = {
  enable_wayland = false,
  animation_fps = 120,
  enable_tab_bar = false,
  font = wezterm.font('Iosevka Nerd Font Mono'),
  font_size = 12,
  color_scheme = "Catppuccin Mocha"
}

return config
