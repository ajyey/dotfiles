# Linux Mac-like Keybindings (`keyd`)

This repository uses **`keyd`** on Linux (specifically Arch/CachyOS) to translate the physical `CMD` (Super/Windows) and `Option` (Alt) keys into a seamless, macOS-like desktop experience.

Because `keyd` runs at the lowest kernel level (`evdev`), it intercepts keystrokes before they ever reach the display server. This means it works flawlessly and universally across both X11 and Wayland without relying on finicky desktop-environment specific tweaks.

## Core Concepts

The configuration is located in `keyd/etc/keyd/default.conf`. You can update and restart the daemon at any time by running `sudo ./scripts/update-keyd.sh`.

### 1. The Inheritance Trick (`CMD` becomes `Ctrl`)
To emulate macOS, we mapped the physical `CMD` (leftmeta) key to activate a custom modifier layer called `meta_mac`. 
The magic happens in how this layer is defined: `[meta_mac:C]`.

The `:C` means the layer **inherits** from `Ctrl`. By default, if you hold `CMD` and press any key, `keyd` silently converts your `CMD` key into a `Ctrl` key.
- `CMD + S` ➔ `Ctrl + S` (Save)
- `CMD + Z` ➔ `Ctrl + Z` (Undo)
- `CMD + F` ➔ `Ctrl + F` (Find)

Because almost all Linux applications use `Ctrl` for shortcuts, this instantly fixes 90% of macOS muscle memory.

### 2. The Overrides
If `CMD` simply became `Ctrl`, we would have a major problem in Terminal emulators: pressing `CMD + C` to copy text would send `Ctrl + C`, instantly killing whatever script is running!

To fix this, we put specific overrides *inside* the `[meta_mac:C]` layer block. These intercept the keystroke before it becomes `Ctrl`:
- **Copy/Paste**: `CMD + C` explicitly sends `Ctrl + Insert`. `CMD + V` sends `Shift + Insert`. This is a universal "safe" copy/paste that Linux GUI apps and Terminals support natively.
- **App Switcher**: `CMD + Tab` doesn't send `Ctrl + Tab`; it uses the `swapm` function to seamlessly translate to `Alt + Tab` and hold the state, perfectly mimicking the macOS app switcher.
- **Text Navigation (Line)**: `CMD + Left/Right Arrow` sends `Home/End`. `CMD + Shift + Left/Right` sends `Shift + Home/End` (macOS text selection). `CMD + Backspace` sends `Ctrl + U` (the universal Linux Readline shortcut to delete to the beginning of the line). `CMD + Delete` sends `Ctrl + K` (delete to end of line).
- **Text Navigation (Word)**: The `Option` (Alt) key layer maps `Option + Left/Right` to `Ctrl + Left/Right` (skipping words). `Option + Backspace` maps to `Ctrl + Backspace` (deleting words). *Note: Terminals expect `Alt+Backspace` for word deletion, so WezTerm intercepts this and manually translates it!*
- **Composite Layers for Shift**: In `keyd`, you cannot bind shifted keys (like `S-left`) inside a standard layer. Instead, shifted behaviors are mapped in dedicated composite layers like `[alt+shift]` and `[meta_mac+shift]`.
- **File Top/Bottom**: `CMD + Up/Down Arrow` sends `Ctrl + Home/End`.
- **Browser History**: `CMD + [` and `CMD + ]` send `Alt + Left/Right` (emulating macOS native browser back/forward navigation).
- **Tab Reordering**: `CMD + Shift + [` and `CMD + Shift + ]` explicitly send `Ctrl + Shift + [` and `Ctrl + Shift + ]`. Because `keyd` recognizes shifted brackets as their physical symbols, these are mapped in the config as `{` and `}` to prevent `keyd`'s cascading inheritance from incorrectly applying shift.
- **Tab Switching (1..9)**: `CMD + 1..9` natively inherits `Ctrl` and sends `Ctrl + 1..9`, seamlessly switching tabs in both browsers and WezTerm. `Option + 1..9` natively sends `Alt + 1..9`, passing cleanly through WezTerm to switch Zellij tabs!

### 3. Application Launcher (The "Tap")
macOS users expect the Start Menu / Application Launcher to behave differently than Windows. By using the `keyd` `overload()` function, we assign dual behaviors to modifiers:
- **Hold**: Acts as the `meta_mac` or `Alt` layer.
- **Tap**: If you simply tap and release `CMD` or `Option` without pressing anything else, `keyd` fires an `Alt+F1` keystroke. `Alt+F1` is the hardcoded system shortcut in KDE Plasma to open the bottom-left application launcher.

### 4. The Hyper Key
Your `Capslock` key acts as `Escape` when tapped. However, when held, it acts as a massive `Hyper` key (`Ctrl + Alt + Shift + Super`), giving you a blank slate to assign global, non-conflicting hotkeys.
- **App Launcher**: `Capslock + Space` (`Hyper + Space`) is mapped inside `keyd` to send `Alt + Space`, instantly triggering the KRunner (Alfred-like) popup launcher in KDE Plasma.
- **Window Management (Rectangle style)**: Hyper is mapped to emulate the macOS "Rectangle" app by silently triggering native KDE Plasma tiling shortcuts:
  - `Hyper + Left/Right/Up/Down`: Snap window to the left, right, top, or bottom half of the screen.
  - `Hyper + Enter`: Maximize window.
  - `Hyper + Backspace`: Minimize/Restore window.

## Zellij Integration

Because we override the `Option` (Alt) layer in `keyd` for macOS text navigation, it introduces some conflicts with terminal multiplexers like Zellij:
- **Pane Navigation**: Zellij normally uses `Alt + Arrow` to switch panes. But because `Option + Left/Right` skips words (`Ctrl + Left/Right`), Zellij pane navigation is explicitly remapped to **`Option + Shift + Arrow`**.
- **Tab Navigation**: Zellij tabs are navigated using `Option + 1..9` (which naturally outputs `Alt + 1..9`). This works perfectly because WezTerm is configured to exclusively use `Ctrl + 1..9`.

## WezTerm Integration

Because `keyd` globally translates the `CMD` key into `Ctrl`, WezTerm on Linux must be configured to listen for `Ctrl`, whereas WezTerm on macOS must listen for `CMD`.

Our WezTerm configuration solves this cleanly by splitting OS-specific keybindings into modular files (`mac.lua` and `linux.lua`). The main `wezterm.lua` dynamically detects your OS and loads the appropriate mappings.

Due to `keyd` overrides and Linux display server quirks, `linux.lua` contains specific workarounds:
- **Copy/Paste**: Listens for the universal `Ctrl+Insert` and `Shift+Insert` (instead of standard `CMD+C`/`CMD+V`).
- **Tab Navigation**: Listens strictly for `Ctrl + 1..9` for numbered tabs to avoid colliding with Zellij. Also listens for `Shift+Home` and `Shift+End` to cycle tabs (since `keyd` translates `CMD+Shift+Left/Right` into these for text selection).
- **Word Deletion**: Listens for `Ctrl + Backspace` (which `keyd` sends when `Option + Backspace` is pressed) and actively translates it into the raw `Alt + Backspace` escape code (`\x1b\x7f`). This bridges the gap between GUI apps (which use `Ctrl`) and Terminal shells (which expect `Alt`).
- **Tab Reordering**: Listens for `{` and `}`. (Wayland/X11 often translates `Shift+[` into the literal `{` keysym).

## Service Management & Debugging

If you ever need to interact with `keyd` directly or debug a misbehaving key, here are the core commands:

### Applying Changes
Instead of doing it manually, we have a script that automatically applies changes from this repository and safely reloads the daemon:
```bash
sudo ./scripts/update-keyd.sh
```

### Native Service Commands
If you prefer to interact with the service directly:
- **Check Status**: `sudo systemctl status keyd`
- **Restart Daemon**: `sudo systemctl restart keyd` (Warning: this will drop any currently held keys)
- **Safe Reload**: `sudo keyd reload` (Instantly applies config changes without dropping held keys)

### Debugging Keystrokes
If a keyboard shortcut isn't working or you want to see exactly what keycode is firing, use the native monitor tool. It will spit out a live feed of every physical key press and what `keyd` is translating it into:
```bash
sudo keyd monitor
```
