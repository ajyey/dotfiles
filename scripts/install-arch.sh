#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_CONFIGS=0
SET_DEFAULT_SHELL=0

usage() {
  cat <<'EOF'
Usage: scripts/install-arch.sh [options]

Install dependencies for this dotfiles repo on CachyOS/Arch-like systems.

Options:
  --stow               Stow fish, fastfetch, and starship configs after install
  --set-default-shell  Change the user's login shell to fish
  -h, --help           Show this help
EOF
}

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

run_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

for arg in "$@"; do
  case "$arg" in
    --stow) STOW_CONFIGS=1 ;;
    --set-default-shell) SET_DEFAULT_SHELL=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage; die "unknown option: $arg" ;;
  esac
done

install_packages() {
  log "Installing CachyOS/Arch packages with pacman"

  local packages=(
    git
    curl
    stow
    fish
    fastfetch
    starship
    wezterm
    eza
    zoxide
    fzf
    fd
    wakeonlan
    mise
    base-devel
    openssl
    zlib
    xz
    tk
    libffi
    readline
    sqlite
    bzip2
  )

  local available=()
  local missing=()
  local package

  for package in "${packages[@]}"; do
    if pacman -Si "$package" >/dev/null 2>&1; then
      available+=("$package")
    else
      missing+=("$package")
    fi
  done

  if [ "${#available[@]}" -gt 0 ]; then
    run_sudo pacman -Syu --needed "${available[@]}"
  fi

  if [ "${#missing[@]}" -gt 0 ]; then
    warn "these pacman packages were unavailable and were skipped: ${missing[*]}"
    warn "install skipped tools manually or from the AUR if you need them."
  fi
}

install_fisher_plugins() {
  if ! has fish; then
    warn "fish is not installed; skipping Fisher plugin setup."
    return
  fi

  local plugin_file="$DOTFILES_DIR/fish/.config/fish/fish_plugins"
  if [ ! -r "$plugin_file" ]; then
    warn "Fish plugin file not found; skipping Fisher plugin setup."
    return
  fi

  local plugins
  plugins="$(grep -Ev '^[[:space:]]*(#|$)' "$plugin_file" | xargs)"

  if [ -z "$plugins" ]; then
    warn "Fish plugin file is empty; skipping Fisher plugin setup."
    return
  fi

  log "Installing Fisher and Fish plugins"
  fish -c '
      if not functions -q fisher
          curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
          fisher install jorgebucaran/fisher
      end
      fisher install '"$plugins"'
  '
}

backup_stow_conflicts() {
  local backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
  local backed_up=0
  local package
  local source
  local relative_path
  local target
  local backup_target

  for package in fish fastfetch starship wezterm mise; do
    while IFS= read -r -d '' source; do
      relative_path="${source#"$DOTFILES_DIR/$package/"}"
      target="$HOME/$relative_path"

      if [ -e "$target" ] && [ "$target" -ef "$DOTFILES_DIR/$package/$relative_path" ]; then
        continue
      fi

      if [ -e "$target" ] || [ -L "$target" ]; then
        backup_target="$backup_dir/$relative_path"
        mkdir -p "$(dirname "$backup_target")"
        mv "$target" "$backup_target"
        backed_up=1
        warn "backed up existing $target to $backup_target"
      fi
    done < <(find "$DOTFILES_DIR/$package" -type f -print0)
  done

  if [ "$backed_up" -eq 1 ]; then
    warn "existing dotfiles were backed up under $backup_dir"
  fi
}

stow_configs() {
  if ! has stow; then
    warn "stow is not installed; skipping config stow."
    return
  fi

  backup_stow_conflicts

  log "Stowing dotfile packages"
  cd "$DOTFILES_DIR"
  stow -t "$HOME" fish fastfetch starship wezterm mise
}

set_default_shell() {
  if ! has fish; then
    warn "fish is not installed; cannot set default shell."
    return
  fi

  local fish_path
  fish_path="$(command -v fish)"

  if ! grep -qxF "$fish_path" /etc/shells; then
    log "Adding fish to /etc/shells"
    printf '%s\n' "$fish_path" | run_sudo tee -a /etc/shells >/dev/null
  fi

  log "Changing default shell to fish"
  chsh -s "$fish_path"
}

install_mise_runtimes() {
  if has mise; then
    log "Installing mise runtimes (node, python, terraform, etc.)"
    mise install
  fi
}

cd "$DOTFILES_DIR"
install_packages
install_fisher_plugins
[ "$STOW_CONFIGS" -eq 1 ] && stow_configs
[ "$STOW_CONFIGS" -eq 1 ] && install_mise_runtimes
[ "$SET_DEFAULT_SHELL" -eq 1 ] && set_default_shell
log "Done"
