local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Load shared appearance and behavior
require('shared').apply(config)

-- Load OS-specific keybindings (currently only macOS is split out)
if wezterm.target_triple:find("darwin") then
  require('mac').apply(config)
end

return config
