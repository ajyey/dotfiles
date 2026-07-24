# Niri macOS-like keybindings (`keyd`)

This guide covers `keyd/etc/keyd/niri.conf` and its matching bindings in `niri/.config/niri/config.kdl`. The KDE profile is documented separately in `keyd.md`.

## Design

Input is split into three roles:

- **Command** (`Super`) activates `[meta_mac:C]`. Unhandled shortcuts become Linux `Ctrl` shortcuts, so Command+S/Z/F behaves like macOS in applications. Explicit overrides provide safe terminal copy/paste, text navigation, app switching, and screenshots.
- **Option** (`Alt`) remains Alt but maps arrows and Delete/Backspace to Linux word-navigation shortcuts.
- **Hyper** (hold Caps Lock) emits Ctrl+Alt+Shift+Super. Niri owns this uncommon chord for compositor and Noctalia actions. Tap Caps Lock for Escape.

Hyper+Tab is the exception: `keyd` emits `F24`, which Niri reserves for toggling to the previously focused workspace. `F20` is avoided because the standard evdev `inet` symbols map it to microphone mute. Command+Tab is not bound by Niri; its standard Alt+Tab output is left for the session's native switcher.

After Command+Tab opens the native switcher, `keyd` enters `app_switch_state`. The layer keeps Alt held until Command is released, which commits the selected window. Tab and Right emit Alt+Tab; Backtick and Left emit Alt+Shift+Tab. The Backtick binding uses keyd's canonical `grave` key name. Niri deliberately leaves both chords unbound so the switcher receives them directly.

Noctalia must accept the Alt-modified navigation chords in `~/.config/noctalia/config.toml`:

```toml
[keybinds]
tab_next = ["tab", "alt+tab"]
tab_previous = ["shift+iso_left_tab", "alt+shift+iso_left_tab"]
```

Command and Option are plain layers in the Niri profile, so tapping either key does nothing. This intentionally differs from the KDE profile's launcher tap.

## Command translations

| Physical shortcut | Emitted shortcut | Niri/application behavior |
|---|---|---|
| Command+Space | Hyper+Space | Toggle Vicinae |
| Command+Tab | Alt+Tab | Open the native application switcher |
| Command+` | Alt+` | Cycle windows in the focused column |
| Command+Shift+3 | Ctrl+Print | Capture the focused screen |
| Command+Shift+4 | Print | Open Niri's region screenshot UI |
| Command+C/V/X | Ctrl+Insert / Shift+Insert / Shift+Delete | Terminal-safe copy/paste/cut |
| Command+Arrow | Home/End or Ctrl+Home/End | macOS-style document navigation |

## Hyper bindings

Hyper already contains Shift, so it cannot have a separate Hyper+Shift tier. Distinct base keys provide secondary actions instead.

| Shortcut | Action | Shortcut | Action |
|---|---|---|---|
| Hyper+Enter | WezTerm (focus, launch, or new window if focused) | Hyper+Space | Vicinae |
| Hyper+Tab (`F24`) | Previous workspace toggle | Hyper+O | Niri overview |
| Hyper+C/V | Control Center / clipboard | Hyper+, | Noctalia settings |
| Hyper+L/Q | Lock / close window | Hyper+Left/Right | Focus column, then adjacent monitor |
| Hyper+Up/Down | Focus stacked window, then previous / next workspace | Hyper+W/S | Reorder stacked window, then move it between workspaces |
| Hyper+A/D | Move column, then to adjacent monitor | Hyper+1..9 | Focus workspace |
| Hyper+U/J | Move current workspace up / down | Hyper+[/] | Combine with or separate from adjacent column |
| Hyper+PageUp/PageDown | Move window to previous / next workspace | Hyper+H/Y/0 | Decrease / increase / reset stacked-window height |
| Hyper+. | Expel window from stacked column | Hyper+vertical wheel | Focus stacked window, then workspace |
| Hyper+horizontal wheel | Focus columns | Hyper+Home/End | Move column between workspaces |
| Hyper+R/-/= | Resize column | Hyper+F/M/G | Maximize column / maximize window / fullscreen |
| Hyper+T | Toggle tabbed column | Hyper+/ | Show Noctalia Keymap panel |
| Hyper+Escape | Suspend the system | | |

Media and brightness keys call Noctalia IPC so its OSD stays synchronized.

## Apply and validate

```bash
keyd check keyd/etc/keyd/niri.conf
niri validate -c niri/.config/niri/config.kdl
sudo ./scripts/update-keyd.sh niri
```

Niri reloads a valid config automatically. Use `sudo keyd monitor` to inspect physical input and `wev` to inspect translated Wayland events.
