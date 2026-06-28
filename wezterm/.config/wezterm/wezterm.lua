local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'rose-pine-moon'
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
  font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
}
config.window_padding = { left = '0.5cell', right = '0.5cell', top = '0.5cell', bottom = '0.5cell' }
config.default_cursor_style = 'BlinkingBar'
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.font_size = 15.0
config.window_frame.font_size = 13.0

-- Override highlight/selection colors for better contrast
config.colors = {
  selection_fg = '#191724', -- Dark background color for text
  selection_bg = '#c4a7e7', -- Iris (Purple) for high contrast highlight
}

config.keys = {
  -- Command Palette (CMD+Shift+P)
  {
    key = 'p',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivateCommandPalette,
  },

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

  -- Go to beginning/end of line (CMD+Left/Right)
  {
    key = 'LeftArrow',
    mods = 'CMD',
    action = wezterm.action.SendString '\x01', -- Ctrl-A
  },
  {
    key = 'RightArrow',
    mods = 'CMD',
    action = wezterm.action.SendString '\x05', -- Ctrl-E
  },

  -- Delete line (CMD+Backspace)
  {
    key = 'Backspace',
    mods = 'CMD',
    action = wezterm.action.SendString '\x15', -- Ctrl-U
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
