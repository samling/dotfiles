local wezterm = require('wezterm')

local config = wezterm.config_builder()

-- local gpus = wezterm.gui.enumerate_gpus()

config.enable_wayland = false
-- config.window_decorations = "NONE"
config.animation_fps = 255
config.wsl_domains = {
    {
        name = "WSL:Ubuntu",
        distribution = "Ubuntu",
        default_cwd = "~"
    },
}
config.enable_kitty_keyboard = true
--- config.webgpu_preferred_adapter = gpus[1]
config.front_end = 'WebGpu' -- WebGpu or OpenGL

config.default_domain = "WSL:Ubuntu"
config.enable_tab_bar = false
config.font = wezterm.font('Iosevka', { weight = 'Regular', stretch = 'Normal' })
config.font_size = 10.5
config.color_scheme = "Catppuccin Mocha"
config.freetype_load_flags = "DEFAULT"

config.window_padding = {
  bottom = 0,
}

config.disable_default_key_bindings = true

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
  },
}

-- for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
--   if gpu.device_type == "DiscreteGpu" then
--     config.webgpu_preferred_adapter = gpu
--     break
--   end
-- end

return config
