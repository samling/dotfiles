local wezterm = require('wezterm')

local config = wezterm.config_builder()

config.enable_wayland = false
config.animation_fps = 120
config.enable_tab_bar = false

config.font = wezterm.font 'Iosevka Nerd Font'
config.font_size = 12

config.window_padding = {
  bottom = 0,
}

config.color_scheme = "Catppuccin Mocha"

config.keys = {
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
  -- Make Option-Right equivalent to Alt-f; forward-word
  {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
}

return config
