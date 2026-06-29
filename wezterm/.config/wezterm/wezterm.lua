local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ====================================================================
-- Appearance & Theme
-- ====================================================================
config.color_scheme = 'rose-pine-moon'
config.font_size = 15.0

-- Override highlight/selection colors for better contrast
config.colors = {
  selection_fg = '#191724', -- Dark background color for text
  selection_bg = '#c4a7e7', -- Iris (Purple) for high contrast highlight
}

-- ====================================================================
-- Window & UI Settings
-- ====================================================================
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.window_padding = { left = '0.5cell', right = '0.5cell', top = '0.5cell', bottom = '0.5cell' }
config.window_close_confirmation = "NeverPrompt"

config.window_frame = {
  font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
  font_size = 13.0,
}

-- ====================================================================
-- Behavior
-- ====================================================================
config.default_cursor_style = 'BlinkingBar'
config.scrollback_lines = 100000

-- Dim inactive panes
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}

-- ====================================================================
-- Keybindings
-- ====================================================================
config.keys = {
  -- ==================== General ====================
  -- Command Palette
  {
    key = 'a',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivateCommandPalette,
  },

  -- ==================== fzf.fish Keybindings ====================
  -- Map CMD+SHIFT+<key> to send Esc+Ctrl+<key> (fzf.fish default for Alt+Ctrl+<key>)
  -- Search files and directories (fzf.fish)
  {
    key = 'f',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString '\x1b\x06', -- \x1b is ESC, \x06 is Ctrl-F
  },
  -- Search git commit log (fzf.fish)
  {
    key = 'l',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString '\x1b\x0c', -- \x0c is Ctrl-L
  },
  -- Search git status / modified files (fzf.fish)
  {
    key = 's',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString '\x1b\x13', -- \x13 is Ctrl-S
  },
  -- Search terminal history (Atuin)
  {
    key = 'r',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString '\x12', -- \x12 is Ctrl-R
  },
  -- Search shell variables (fzf.fish)
  {
    key = 'v',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString '\x16', -- \x16 is Ctrl-V
  },

  -- ==================== Panes & Splits ====================
  -- Split pane (iTerm2 style: CMD+D / CMD+Shift+D)
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

  -- Close current pane/tab
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },

  -- Navigate between panes
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

  -- ==================== Tabs ====================
  -- New tab
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },

  -- Navigate adjacent tabs (CMD+Shift+[ and CMD+Shift+])
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

  -- Rename current tab
  {
    key = 'r',
    mods = 'CMD',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- ==================== Text / Line Editing ====================
  -- Go to beginning of line (sends Ctrl-A)
  {
    key = 'LeftArrow',
    mods = 'CMD',
    action = wezterm.action.SendString '\x01',
  },
  -- Go to end of line (sends Ctrl-E)
  {
    key = 'RightArrow',
    mods = 'CMD',
    action = wezterm.action.SendString '\x05',
  },
  -- Delete whole line / delete to beginning (sends Ctrl-U)
  {
    key = 'Backspace',
    mods = 'CMD',
    action = wezterm.action.SendString '\x15',
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

-- ====================================================================
-- Mouse Behavior
-- ====================================================================
config.mouse_bindings = {
  -- Cmd-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

return config
