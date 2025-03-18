local wezterm = require('wezterm')

local config = wezterm.config_builder()

config.enable_wayland = false
config.animation_fps = 120
config.enable_tab_bar = false

config.enable_kitty_keyboard = true

config.font = wezterm.font_with_fallback {'Iosevka', 'Iosevka Nerd Font Propo'}
config.font_size = 12

config.window_padding = {
  bottom = 0,
}

config.color_scheme = "Catppuccin Mocha"
config.warn_about_missing_glyphs=false

config.disable_default_key_bindings=true
config.keys = {
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
  -- Make Option-Right equivalent to Alt-f; forward-word
  {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
  {
    key = "P",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ActivateCommandPalette,
  },
  {
    key = "C",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CopyTo('Clipboard'),
  },
  {
    key = "V",
    mods = "CTRL|SHIFT",
    action = wezterm.action.PasteFrom('Clipboard'),
  }
}

return config
