local wezterm = require('wezterm')
local mux = wezterm.mux
local act = wezterm.action
-- local gpus = wezterm.gui.enumerate_gpus()

local config = {
  enable_wayland = false,
  animation_fps = 120,
  wsl_domains = {
      {
          name = "WSL:Ubuntu",
          distribution = "Ubuntu",
          default_cwd = "~"
      },
  },
  -- webgpu_preferred_adapter = gpus[1],
  front_end = 'OpenGL', -- WebGpu or OpenGL
  default_domain = "WSL:Ubuntu",
  enable_tab_bar = false,
  font = wezterm.font('Iosevka Nerd Font Mono'),
  font_size = 12,
  color_scheme = "Catppuccin Mocha"

}
local keys = {}
local mouse_bindings = {}
local launch_menu = {}

for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
  if gpu.device_type == "DiscreteGpu" then
    config.webgpu_preferred_adapter = gpu
    break
  end
end

return config
