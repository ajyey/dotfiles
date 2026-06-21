#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_CONFIGS=0
SET_DEFAULT_SHELL=0

usage() {
  cat <<'EOF'
Usage: scripts/install-mac.sh [options]

Install dependencies for this dotfiles repo on macOS.

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
  if ! has brew; then
    die "Homebrew is required on macOS. Install it from https://brew.sh, then rerun this script."
  fi

  cd "$DOTFILES_DIR"

  if [ -f Brewfile ]; then
    log "Installing macOS packages from Brewfile"
    brew bundle --file Brewfile
    return
  fi

  warn "Brewfile not found; installing the fallback package list."
  warn "Add these formulas to Brewfile: git, curl, stow, fish, fastfetch, starship, eza, zoxide, fzf, fd, wakeonlan."

  log "Installing macOS packages with Homebrew"
  brew update
  brew install git curl stow fish fastfetch starship eza zoxide fzf fd wakeonlan
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

stow_configs() {
  if ! has stow; then
    warn "stow is not installed; skipping config stow."
    return
  fi

  log "Stowing dotfile packages"
  cd "$DOTFILES_DIR"
  stow fish fastfetch starship
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

cd "$DOTFILES_DIR"
install_packages
install_fisher_plugins
[ "$STOW_CONFIGS" -eq 1 ] && stow_configs
[ "$SET_DEFAULT_SHELL" -eq 1 ] && set_default_shell
log "Done"
