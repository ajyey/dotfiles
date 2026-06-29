# Repository Guidelines

## Project Structure & Module Organization

This is a GNU Stow dotfiles repository. Each top-level directory is a Stow package whose internal paths mirror `$HOME`.

- `fish/.config/fish/` contains Fish shell configuration, completions, and `fish_plugins`. OS-specific configurations are in `fish/.config/fish/os_specific/`.
- `fastfetch/.config/fastfetch/config.jsonc` contains the Fastfetch startup display.
- `starship/.config/starship.toml` contains the Starship prompt theme.
- `wezterm/.config/wezterm/wezterm.lua` contains the WezTerm configuration with fzf.fish keybindings.
- `zellij/.config/zellij/config.kdl` contains the Zellij terminal multiplexer configuration.
- `mise/.config/mise/config.toml` manages global runtimes and tools (Node, Python, Go, Zellij, Ripgrep).
- `install.sh` generic installation script that detects OS and delegates to `scripts/install-*.sh`.
- `README.md` documents setup and restore steps.

Do not commit generated or machine-specific Fish files. `.gitignore` excludes `fish_variables`, `functions/`, and `conf.d/`; keep `fish_plugins` tracked.

## Build, Test, and Development Commands

- `stow fish`, `stow fastfetch`, `stow starship`, `stow wezterm`, `stow zellij`, `stow mise`: symlink a package into `$HOME`.
- `stow -D fish`: remove Fish symlinks without deleting repository files.
- `fish -n fish/.config/fish/config.fish`: syntax-check the main Fish config.
- `fastfetch --config fastfetch/.config/fastfetch/config.jsonc`: preview Fastfetch output.
- `starship explain`: inspect the active prompt modules after stowing Starship config.
- `fisher update`: install Fish plugins listed in `fish_plugins`.
- `./install.sh --stow`: generic installation and stow command.

Run commands from the repository root unless a tool requires the live `$HOME` path.

## Coding Style & Naming Conventions

Use the style already present in each config file. Fish scripts use 4-space indentation inside functions and `# ===` section comments for major groups. Prefer guarded integrations such as `if type -q starship` or `if test -f ...` so configs remain portable across machines.

TOML files use quoted strings and grouped module sections. JSONC files use 4-space indentation and may include comments where supported.

## Testing Guidelines

There is no formal automated test suite. Validate changed configs with the relevant tool before committing. For Fish changes, run `fish -n` and open a new Fish shell or `exec fish` to verify aliases, PATH changes, and startup behavior. For visual prompt or Fastfetch changes, test in a terminal that supports Nerd Font glyphs.

## Commit & Pull Request Guidelines

Recent commits use short, imperative messages such as `adds starship`, `add zoxide`, and `fix iterm vars`. Keep messages concise and focused on one config change.

Pull requests should describe the affected package, list validation commands run, and call out machine-specific assumptions such as macOS paths, LAN host aliases, or required tools like `eza`, `zoxide`, `mise`, `fastfetch`, `starship`, `zellij`, and `bat`.

## Documentation Maintenance
**CRITICAL RULE:** Whenever you add a new tool, package, script, or make architectural changes to this repository, you **MUST** ensure that both `AGENTS.md` and `README.md` are simultaneously updated to document the new work. Never leave the documentation out of sync with the actual repository state.
