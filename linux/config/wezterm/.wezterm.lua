local wezterm = require('wezterm')

local config = wezterm.config_builder()

config.enable_wayland = false
config.animation_fps = 120
config.enable_tab_bar = false

config.font = wezterm.font 'Iosevka Nerd Font Mono'
config.font_size = 12

config.color_scheme = "Catppuccin Mocha"

return config
