local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.keys = {
  -- Split pane (like iTerm2 CMD+D and CMD+Shift+D)
  -- Note: WezTerm's SplitHorizontal means left/right panes, 
  -- which is what iTerm2 calls a vertical split.
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'D',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- Close pane/tab (CMD+W)
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },

  -- New tab (CMD+T)
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },

  -- Navigate tabs (CMD+Shift+[ and CMD+Shift+])
  {
    key = '{',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = '}',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivateTabRelative(1),
  },

  -- Navigate panes (CMD+Option+Arrows)
  {
    key = 'LeftArrow',
    mods = 'CMD|OPT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'CMD|OPT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'CMD|OPT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'CMD|OPT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
}

-- Add tab navigation for CMD+1 through CMD+9
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CMD',
    action = wezterm.action.ActivateTab(i - 1),
  })
end

return config
