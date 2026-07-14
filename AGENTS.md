# Repository Guidelines

## Project Structure & Module Organization

This is a GNU Stow dotfiles repository. Each configuration package mirrors its destination under `$HOME`:

- `fish/.config/fish/` contains the Fish startup config, tracked plugin list, and OS-specific settings in `os_specific/`.
- `fastfetch/`, `starship/`, `wezterm/`, `zellij/`, `niri/`, and `mise/` contain their respective files under `.config/`.
- `keyd/etc/keyd/` contains Linux keyboard mappings installed at the system level rather than Stowed into `$HOME`.
- `install.sh` detects the host OS and delegates to `scripts/install-{arch,debian,mac}.sh`; `scripts/update-keyd.sh` deploys the appropriate keyd profile.
- `README.md` covers installation and usage. `keyd.md` documents the KDE keyboard profile; `keyd-niri.md` documents Niri and Noctalia bindings.

Do not commit generated Fish state. `.gitignore` excludes `fish_variables`, generated `functions/`, `conf.d/`, and completions; keep `fish_plugins` tracked.

## Build, Test, and Development Commands

Run commands from the repository root.

- `./install.sh --stow`: install supported dependencies and Stow user configurations for the detected OS.
- `stow -t ~ fish` (or another package): create that package's home-directory symlinks.
- `stow -D fish`: remove Fish symlinks without deleting repository files.
- `fish -n fish/.config/fish/config.fish`: syntax-check the main Fish configuration.
- `fastfetch --config fastfetch/.config/fastfetch/config.jsonc`: preview Fastfetch changes.
- `fisher update`: synchronize plugins from `fish_plugins`.

## Coding Style & Naming Conventions

Follow the surrounding format. Use four-space indentation inside Fish functions and `# ===` comments for major sections. Guard optional tools with `if type -q <tool>` or file checks so startup remains portable. Keep TOML settings grouped and quoted; indent JSONC with four spaces.

Define cross-platform aliases separately in `mac.fish`, `arch.fish`, and `debian.fish`, using the correct package manager for each platform.

## Testing Guidelines

There is no automated test suite or coverage target. Validate every changed format with its native tool. For Fish changes, run `fish -n` and start a fresh shell with `exec fish`. Test prompt, terminal, compositor, and glyph changes interactively in their target environment.

## Commit & Pull Request Guidelines

Use short, focused, imperative commits. Recent history commonly uses Conventional Commit forms such as `fix(wezterm): ...`, `feat(keyd): ...`, and `docs: ...`; plain imperative messages are also present. Pull requests should identify affected packages, list validation performed, and disclose OS, path, hardware, or required-tool assumptions. Include screenshots only for visible UI changes.

## Documentation Maintenance

When adding a tool, package, script, or architectural change, update both `AGENTS.md` and `README.md`. Changes to `keyd/etc/keyd/kde.conf` must update `keyd.md`; changes to `keyd/etc/keyd/niri.conf` must update `keyd-niri.md`. Explain the technical rationale, layer behavior, and compositor-side bindings.
