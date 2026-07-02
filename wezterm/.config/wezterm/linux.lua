local wezterm = require 'wezterm'

return {
  apply = function(config)
    -- ====================================================================
    -- Keybindings (Linux via keyd)
    -- ====================================================================
    -- Note: On Linux, we use `keyd` to translate the physical CMD/Super key 
    -- into the Ctrl key globally. Therefore, WezTerm listens for 'CTRL' 
    -- rather than 'SUPER'.
    
    config.keys = {
      -- ==================== General ====================
      -- New Window (keyd maps CMD+N → CTRL+N)
      {
        key = 'n',
        mods = 'CTRL',
        action = wezterm.action.SpawnWindow,
      },

      -- Command Palette
      {
        key = 'a',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateCommandPalette,
      },

      -- ==================== Copy & Paste (keyd support) ====================
      -- keyd maps CMD+C to Ctrl+Insert and CMD+V to Shift+Insert.
      -- WezTerm natively maps these to PrimarySelection, but we want the Clipboard!
      {
        key = 'Insert',
        mods = 'CTRL',
        action = wezterm.action.CopyTo 'Clipboard',
      },
      {
        key = 'Insert',
        mods = 'SHIFT',
        action = wezterm.action.PasteFrom 'Clipboard',
      },

      -- ==================== fzf.fish Keybindings ====================
      {
        key = 'f',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SendString '\x1b\x06',
      },
      {
        key = 'l',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SendString '\x1b\x0c',
      },
      {
        key = 's',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SendString '\x1b\x13',
      },
      {
        key = 'r',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SendString '\x12',
      },
      {
        key = 'v',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SendString '\x16',
      },

      -- ==================== Panes & Splits ====================
      {
        key = 'd',
        mods = 'CTRL',
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
      },
      {
        key = 'D',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
      },
      {
        key = 'w',
        mods = 'CTRL',
        action = wezterm.action.CloseCurrentPane { confirm = true },
      },
      {
        key = 'LeftArrow',
        mods = 'CTRL|OPT',
        action = wezterm.action.ActivatePaneDirection 'Left',
      },
      {
        key = 'RightArrow',
        mods = 'CTRL|OPT',
        action = wezterm.action.ActivatePaneDirection 'Right',
      },
      {
        key = 'UpArrow',
        mods = 'CTRL|OPT',
        action = wezterm.action.ActivatePaneDirection 'Up',
      },
      {
        key = 'DownArrow',
        mods = 'CTRL|OPT',
        action = wezterm.action.ActivatePaneDirection 'Down',
      },

      -- ==================== Tabs ====================
      {
        key = 't',
        mods = 'CTRL',
        action = wezterm.action.SpawnTab 'CurrentPaneDomain',
      },
      {
        key = 'LeftArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateTabRelative(-1),
      },
      {
        key = 'RightArrow',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateTabRelative(1),
      },
      {
        key = 'r',
        mods = 'CTRL',
        action = wezterm.action.PromptInputLine {
          description = wezterm.format {
            { Attribute = { Intensity = 'Bold' } },
            { Foreground = { Color = '#c4a7e7' } },
            { Text = 'Enter new name for tab ✏️ :' },
          },
          action = wezterm.action_callback(function(window, pane, line)
            if line then
              window:active_tab():set_title(line)
            end
          end),
        },
      },
      {
        key = '[',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.MoveTabRelative(-1),
      },
      {
        key = ']',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.MoveTabRelative(1),
      },

      -- ==================== Text / Line Editing ====================
      {
        key = 'LeftArrow',
        mods = 'CTRL',
        action = wezterm.action.SendString '\x01',
      },
      {
        key = 'RightArrow',
        mods = 'CTRL',
        action = wezterm.action.SendString '\x05',
      },
      {
        key = 'Backspace',
        mods = 'CTRL',
        action = wezterm.action.SendString '\x15',
      },
    }

    -- Add tab navigation for CMD+1 through CMD+9
    -- Note: keyd maps CMD+1..9 to Alt+1..9 natively, so we listen for ALT
    for i = 1, 9 do
      table.insert(config.keys, {
        key = tostring(i),
        mods = 'ALT',
        action = wezterm.action.ActivateTab(i - 1),
      })
    end

    -- ====================================================================
    -- Mouse Behavior
    -- ====================================================================
    config.mouse_bindings = {
      {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'SUPER',
        action = wezterm.action.OpenLinkAtMouseCursor,
      },
    }
  end
}
