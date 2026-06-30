local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Load shared appearance and behavior
require('shared').apply(config)

-- Load OS-specific keybindings
if wezterm.target_triple:find("darwin") then
  require('mac').apply(config)
elseif wezterm.target_triple:find("linux") then
  require('linux').apply(config)
end

return config
