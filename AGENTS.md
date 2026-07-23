# Repository Guide

## Repository Model

- This is a GNU Stow repository: each user-config package mirrors its path below `$HOME` (for example, `fish/.config/fish/config.fish` becomes `~/.config/fish/config.fish`).
- `keyd/` is the exception. It contains system configuration; `scripts/update-keyd.sh` copies one profile to `/etc/keyd/default.conf` and reloads or enables the service. Do not Stow it.
- `install.sh` only detects Debian, Arch, or macOS and delegates to `scripts/install-*.sh`. These scripts install packages and Fisher plugins; `--stow` also backs up conflicting files to `~/.dotfiles-backup/<timestamp>/`, Stows configs, and installs Mise runtimes. Avoid running an installer merely to validate edits.
- Arch Stows `niri`; Debian and macOS do not. All three Stow `fish fastfetch starship wezterm zellij mise agents`.
- The `agents` package maps `agents/.agents/skills/` to `~/.agents/skills`. Every repository-managed skill must use `agents/.agents/skills/<name>/SKILL.md`, which installs as `~/.agents/skills/<name>/SKILL.md`; keep supporting resources inside the same `<name>/` directory.
- The `niri` package also installs `.config/environment.d/10-kde-on-niri.conf` so systemd-activated Qt applications and portals inherit KDE integration settings. Changes require a user-manager re-exec and a fresh login session.
- Fish loads exactly one file from `fish/.config/fish/os_specific/` based on `uname` and `/etc/{debian_version,arch-release}`. Keep OS-specific paths and package-manager behavior in the matching file.
- Do not add generated Fisher state. `.gitignore` excludes `fish_variables`, `functions/`, `conf.d/`, and `completions/`; `fish/.config/fish/fish_plugins` is the tracked plugin source.

## Coupled Configuration

- Linux shortcuts pass through `keyd` before WezTerm, Zellij, and Niri. When changing emitted key chords, inspect the consumers in `wezterm/.config/wezterm/linux.lua`, `zellij/.config/zellij/config.kdl`, and `niri/.config/niri/config.kdl` rather than treating a profile in isolation.
- Keep `keyd.md` synchronized with `keyd/etc/keyd/kde.conf`. Keep `keyd-niri.md` synchronized with both `keyd/etc/keyd/niri.conf` and matching Niri/Noctalia bindings.
- `wezterm/.config/wezterm/wezterm.lua` applies `shared.lua`, then `mac.lua` or `linux.lua` from `wezterm.target_triple`.
- `mise/.config/mise/config.toml` is global runtime state. Install scripts run `mise install` only when `--stow` is supplied; Fish update functions use `mise upgrade --bump`, which may rewrite pinned versions.
- The macOS `brew` Fish wrapper regenerates the root `Brewfile` after `brew install` or `brew uninstall`. `scripts/install-mac.sh --brewfile` installs that full machine inventory, not only core dotfile dependencies.

## Focused Validation

There is no aggregate test task or CI workflow. Run validators relevant to changed files from the repository root:

```bash
bash -n install.sh scripts/*.sh
fish -n fish/.config/fish/config.fish fish/.config/fish/os_specific/*.fish
fastfetch --config fastfetch/.config/fastfetch/config.jsonc
wezterm --config-file wezterm/.config/wezterm/wezterm.lua show-keys --key-table default
keyd check keyd/etc/keyd/kde.conf
keyd check keyd/etc/keyd/niri.conf
niri validate -c niri/.config/niri/config.kdl
stow -n -v -t "$HOME" fish  # replace fish with the changed package
```

After syntax validation, terminal, compositor, prompt, glyph, and keyboard behavior still require interactive testing on the target OS. Apply a keyd profile explicitly with `sudo ./scripts/update-keyd.sh kde` or `sudo ./scripts/update-keyd.sh niri`; omitting the profile auto-detects the desktop and defaults to KDE if detection fails.
