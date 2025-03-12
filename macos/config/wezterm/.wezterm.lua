local wezterm = require('wezterm')

local config = wezterm.config_builder()

config.enable_wayland = false
config.animation_fps = 120
config.enable_tab_bar = false

config.font = wezterm.font('Iosevka')
config.font_size = 16

config.color_scheme = "Catppuccin Mocha"

config.window_decorations = "RESIZE"

config.disable_default_key_bindings = true
config.keys = {
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
  -- Make Option-Right equivalent to Alt-f; forward-word
  {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
  {
    key = "P",
    mods = "CMD|SHIFT",
    action = wezterm.action.ActivateCommandPalette
  },
  {
    key = "P",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ActivateCommandPalette
  },
  {
    key = "C",
    mods = "CMD|SHIFT",
    action = wezterm.action.CopyTo('Clipboard')
  },
  {
    key = "C",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CopyTo('Clipboard')
  },
  {
    key = "P",
    mods = "CMD|SHIFT",
    action = wezterm.action.PasteFrom('Clipboard')
  },
  {
    key = "P",
    mods = "CTRL|SHIFT",
    action = wezterm.action.PasteFrom('Clipboard')
  },
}

return config
