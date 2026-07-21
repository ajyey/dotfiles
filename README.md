# Dotfiles Managed with GNU Stow

This repo manages dotfiles with [GNU Stow](https://www.gnu.org/software/stow/) by symlinking package directories into `$HOME`. It currently tracks Fish shell, Fastfetch, Starship, WezTerm, Zellij, Niri, and global Mise configuration.

## Requirements

- macOS, Debian, or CachyOS/Arch
- Git access to this repository
- `sudo` access for Linux package installs and optional shell changes

The install scripts set up GNU Stow, Fish, Fisher plugins, Fastfetch, Starship, and the terminal helpers used by `config.fish`.

## Repo Structure

```bash
~/.dotfiles/
├── fish/
│   └── .config/fish/
│       ├── config.fish
│       ├── fish_plugins
│       └── completions/
├── fastfetch/
│   └── .config/fastfetch/config.jsonc
├── starship/
│   └── .config/starship.toml
├── wezterm/
│   └── .config/wezterm/
│       ├── wezterm.lua
│       ├── shared.lua
│       ├── mac.lua
│       └── linux.lua
├── zellij/
│   └── .config/zellij/config.kdl
├── niri/
│   └── .config/niri/
│       ├── config.kdl
│       └── dms/
└── mise/
    └── .config/mise/config.toml
```

Each top-level directory is a Stow package whose internal paths mirror `$HOME`.

## macOS Setup

1. Install Homebrew if it is not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Clone this repo:

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
```

3. Add a `Brewfile` to this repo if you want Homebrew dependencies versioned. Include at least:

```ruby
brew "git"
brew "curl"
brew "stow"
brew "fish"
brew "fastfetch"
brew "starship"
brew "wezterm"
brew "eza"
brew "zoxide"
brew "fzf"
brew "fd"
brew "wakeonlan"
```

4. Install packages, Fisher plugins, and symlink configs:

```bash
scripts/install-mac.sh --stow
```

5. Optionally make Fish your login shell:

```bash
scripts/install-mac.sh --set-default-shell
```

## Debian Setup

1. Install Git if the machine does not have it:

```bash
sudo apt update
sudo apt install git
```

2. Clone this repo:

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
```

3. Install packages, Fisher plugins, and symlink configs:

```bash
scripts/install-debian.sh --stow
```

4. Optionally make Fish your login shell:

```bash
scripts/install-debian.sh --set-default-shell
```

Some Debian releases may not package every tool, such as `fastfetch`, `starship`, `wezterm`, `eza`, or `zoxide`. The script skips unavailable packages with a warning so the rest of the setup can finish.

## CachyOS / Arch Setup

1. Install Git if the machine does not have it:

```bash
sudo pacman -Syu --needed git
```

2. Clone this repo:

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
```

3. Install packages, Fisher plugins, and symlink configs:

```bash
./install.sh --stow
```

4. Optionally make Fish your login shell:

```bash
./install.sh --set-default-shell
```

5. Optionally install everything from a Brewfile on macOS (instead of defaults):

```bash
./install.sh --brewfile
```

If `wakeonlan` is not available from the enabled pacman repositories, the script skips it with a warning. Install it manually or from the AUR if you need the `cachywake` alias.

## Common Commands

Stow packages manually:

```bash
stow -t ~ fish
stow -t ~ fastfetch
stow -t ~ starship
stow -t ~ wezterm
stow -t ~ zellij
stow -t ~ niri
stow -t ~ mise
```

When install scripts run with `--stow`, they first back up conflicting real files from `$HOME` into `~/.dotfiles-backup/<timestamp>/`. This handles fresh machines that already have files such as `~/.config/fish/config.fish` before Stow creates symlinks.

To remove symlinks without deleting files:

```bash
stow -D fish
```

Reload Fish after changes:

```fish
exec fish
```

## Upgrading Packages

### System Packages
To upgrade your system-level packages (installed via Homebrew, apt, or pacman), you can use the aliases provided in your Fish shell (e.g., typing `update` on macOS).

The following package management aliases are available and map to the appropriate tool per OS:

| Alias | macOS | Debian | Arch / CachyOS |
|-------|-------|--------|----------------|
| `search <term>` | `brew search` | `apt search` | `shelly search` / `pacman -Ss` |
| `install <pkg>` | `brew install` | `sudo apt install` | `shelly install` / `sudo pacman -S` |
| `uninstall <pkg>` | `brew uninstall` | `sudo apt purge` | `shelly remove` / `sudo pacman -Rns` |

On macOS, `install` and `uninstall` route through the `brew` wrapper function, which automatically keeps your `Brewfile` up to date.

### Mise Packages (Runtimes & Tools)
Because most of the modern CLI tools and runtimes (like Node, Python, Zellij, Neovim, Ripgrep) are managed by `mise`, they won't update automatically with your system packages.

To update all your `mise` packages to their latest versions, simply run:

```bash
mise up
```

This will read your `mise/.config/mise/config.toml`, download the latest versions, and automatically update your configuration file.

## Linux Mac-like Keybindings (keyd)

On Arch/CachyOS, this repository uses **`keyd`** to map the `CMD` (Super/Windows) key to behave exactly like macOS across the entire Linux desktop. 
Because `keyd` runs at the lowest kernel level (evdev), it works flawlessly on both X11 and Wayland.

The desktop configurations are tracked in `keyd/etc/keyd/` as `kde.conf` and `niri.conf`. `scripts/install-arch.sh` installs the detected profile; `sudo ./scripts/update-keyd.sh [kde|niri]` can deploy one explicitly.

The profiles have separate guides because their compositor shortcuts differ:

- [`keyd.md`](keyd.md) documents the KDE Plasma profile.
- [`keyd-niri.md`](keyd-niri.md) documents the Niri profile, its Hyper bindings, and Noctalia integration.

## KDE Applications Under Niri

The Niri package also Stows `.config/environment.d/10-kde-on-niri.conf` so Dolphin and other KDE applications use the palette and application metadata from `~/.config/kdeglobals`:

```conf
QT_QPA_PLATFORMTHEME=kde
XDG_MENU_PREFIX=plasma-
```

These variables belong in `environment.d` rather than only Niri's `environment` block. KDE portals and other systemd-activated user services start outside Niri's child-process environment and need the variables from the user manager at login.

The setup expects `plasma-integration` for the KDE Qt platform theme. Dolphin integration additionally benefits from `systemsettings`, `xdg-desktop-portal-kde`, `ffmpegthumbnailer`, and `ffmpegthumbs`.

After adding or changing the environment file, apply it with:

```bash
stow -t "$HOME" niri
systemctl --user daemon-reexec
XDG_MENU_PREFIX=plasma- kbuildsycoca6 --noincremental
```

Log out and back into Niri afterward. Existing launchers, portals, and applications cannot inherit environment changes retroactively. Selecting the KDE portal as the default file picker is separate from Dolphin theming and requires a user `xdg-desktop-portal` preference file.

## Modular WezTerm

Because `keyd` translates the `CMD` key into `Ctrl`, WezTerm on Linux must be configured to listen for `Ctrl`, whereas WezTerm on macOS must listen for `CMD`. 

To solve this, the WezTerm configuration in `.config/wezterm/` is completely modular:
- `shared.lua`: Contains all appearance, fonts, and window behavior.
- `mac.lua`: Contains the native macOS `CMD` keybindings.
- `linux.lua`: Contains the translated `CTRL` keybindings (and explicitly routes `Ctrl+Insert` to the Clipboard).
- `wezterm.lua`: A lightweight entrypoint that dynamically loads the correct files based on your current OS.

## WezTerm Keybindings

The following custom keybindings are configured for WezTerm in this dotfiles repository:

| Action | Shortcut |
|--------|----------|
| **General** | |
| Open Command Palette | `⌘ + Shift + A` |
| Open Link under Cursor | `⌘ + Click` (Mouse) |
| **Search / fzf** | |
| Search Files & Directories | `⌘ + Shift + F` |
| Search Git Commit Log | `⌘ + Shift + L` |
| Search Git Status | `⌘ + Shift + S` |
| Search Shell Variables | `⌘ + Shift + V` |
| Search Command History (Atuin) | `⌘ + Shift + R` |
| **Panes** | |
| Split Pane Vertically (Left/Right) | `⌘ + D` |
| Split Pane Horizontally (Top/Bottom) | `⌘ + Shift + D` |
| Close Pane / Tab | `⌘ + W` |
| Navigate Panes | `⌘ + Option + Arrow Keys` |
| **Tabs** | |
| New Tab | `⌘ + T` |
| Navigate Adjacent Tabs | `⌘ + Shift + Left/Right Arrow` |
| Jump to Specific Tab | `⌘ + 1` through `9` |
| Rename Current Tab | `⌘ + R` |
| Move Tab Left / Right | `⌘ + Shift + [` / `]` |
| **Text Editing** | |
| Go to Beginning of Line | `⌘ + Left Arrow` |
| Go to End of Line | `⌘ + Right Arrow` |
| Delete Line | `⌘ + Backspace` |

## Fish Plugins

Plugins are managed with Fisher and listed in `fish/.config/fish/fish_plugins`.

Install Fisher inside Fish:

```fish
curl -sL https://git.io/fisher | source
```

Install plugins from the tracked list:

```fish
fisher update
```

After adding or removing plugins, update the tracked list:

```fish
fisher list > ~/.config/fish/fish_plugins
```

## Cross-Platform Notes

`config.fish` dynamically sources OS-specific configurations from `os_specific/*.fish` to ensure the correct Homebrew/Linuxbrew paths, 1Password sockets, and update aliases are loaded based on your machine (`macOS`, `Debian`, or `Arch`). Optional integrations are guarded so the shell can start cleanly even when tools are missing.

Personal SSH aliases and Wake-on-LAN shortcuts remain available globally but may only work on your home network. Machine-specific Fish files are ignored: `fish_variables`, `functions/`, and `conf.d/`.

### Remote Dev / SSH Autostart
When you SSH into a remote machine running this configuration, Fish will automatically launch and attach to a persistent Zellij session named `ssh`. If your connection drops, your workspace is perfectly preserved!

To bypass this auto-start and get a raw shell (for example, to attach to a differently named session), you can inject the `ZELLIJ` environment variable in your SSH command:
```bash
ssh -t user@host "env ZELLIJ=1 fish"
```

## Saving Changes

Edit configs through their normal `$HOME` paths or directly in this repo, then commit the package file:

```bash
git add fish/.config/fish/config.fish
git commit -m "Update fish config"
git push
```
