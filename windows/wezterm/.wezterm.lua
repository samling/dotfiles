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
--- config.front_end = 'WebGpu' -- WebGpu or OpenGL

config.default_domain = "WSL:Ubuntu"
config.enable_tab_bar = false
config.font = wezterm.font('Iosevka Nerd Font Propo')
config.font_size = 10
config.color_scheme = "Catppuccin Mocha"

-- config.window_padding = {
--   bottom = 10,
--   top = 10,
--   left = 10,
--   right = 10,
-- }

config.disable_default_key_bindings = true

-- for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
--   if gpu.device_type == "DiscreteGpu" then
--     config.webgpu_preferred_adapter = gpu
--     break
--   end
-- end

return config
