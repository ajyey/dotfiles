#!/usr/bin/env bash
set -euo pipefail

# Generic install script that delegates to the appropriate OS-specific script

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

case "${OS}" in
    Linux*)
        if [ -f /etc/debian_version ]; then
            exec "${DOTFILES_DIR}/scripts/install-debian.sh" "$@"
        elif [ -f /etc/arch-release ]; then
            exec "${DOTFILES_DIR}/scripts/install-arch.sh" "$@"
        else
            echo "error: Unsupported Linux distribution." >&2
            exit 1
        fi
        ;;
    Darwin*)
        exec "${DOTFILES_DIR}/scripts/install-mac.sh" "$@"
        ;;
    *)
        echo "error: Unsupported operating system: ${OS}" >&2
        exit 1
        ;;
esac
