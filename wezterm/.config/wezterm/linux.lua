local wezterm = require 'wezterm'

return {
  apply = function(config)
    -- Force XWayland instead of native Wayland so that cliboard contents can be shared across wezterm windows/processes
    config.enable_wayland = false

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
      -- NOTE: We use ClipboardAndPrimarySelection here because on Wayland, copying 
      -- strictly to just the Clipboard can fail to sync across completely separate Wezterm window instances!
      {
        key = 'Insert',
        mods = 'CTRL',
        action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
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
        -- keyd maps CMD+Shift+Left to Shift+Home globally (macOS text selection).
        key = 'Home',
        mods = 'SHIFT',
        action = wezterm.action.ActivateTabRelative(-1),
      },
      {
        -- keyd maps CMD+Shift+Right to Shift+End globally.
        key = 'End',
        mods = 'SHIFT',
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
        key = '{',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.MoveTabRelative(-1),
      },
      {
        key = '{',
        mods = 'CTRL',
        action = wezterm.action.MoveTabRelative(-1),
      },
      {
        key = ']',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.MoveTabRelative(1),
      },
      {
        key = '}',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.MoveTabRelative(1),
      },
      {
        key = '}',
        mods = 'CTRL',
        action = wezterm.action.MoveTabRelative(1),
      },

      -- ==================== Text / Line Editing ====================
      -- keyd maps Option+Left/Right to Ctrl+Left/Right for global word navigation.
      -- To make Zellij pane navigation (Alt+Left/Right) work natively, we intercept 
      -- the Ctrl+Left/Right signal inside Wezterm and translate it back to Alt+Left/Right!
      {
        key = 'LeftArrow',
        mods = 'CTRL',
        action = wezterm.action.SendString '\x1b[1;3D',
      },
      {
        key = 'RightArrow',
        mods = 'CTRL',
        action = wezterm.action.SendString '\x1b[1;3C',
      },
      -- keyd maps Option+Backspace to Ctrl+Backspace (which works perfectly in GUI apps).
      -- Terminals usually expect Alt+Backspace for word deletion, so we manually 
      -- intercept Ctrl+Backspace and send the Alt+Backspace ANSI escape sequence!
      {
        key = 'Backspace',
        mods = 'CTRL',
        action = wezterm.action.SendString '\x1b\x7f',
      },
    }

    -- Add tab navigation for CMD+1 through CMD+9
    -- Note: keyd natively translates CMD+1..9 into Ctrl+1..9, so we listen for CTRL.
    -- This perfectly separates Wezterm tabs (CTRL) from Zellij tabs (ALT)!
    for i = 1, 9 do
      table.insert(config.keys, {
        key = tostring(i),
        mods = 'CTRL',
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
