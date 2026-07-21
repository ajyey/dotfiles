#!/usr/bin/env bash
set -e

# Make sure we're running as root for system-level changes
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo ./scripts/update-keyd.sh)"
  exit 1
fi

# Get the absolute path to the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -n "$1" ]; then
  DE="$1"
elif pgrep -x niri > /dev/null; then
  DE="niri"
  echo "Auto-detected Niri desktop environment."
elif pgrep -x plasmashell > /dev/null || pgrep -x kwin_wayland > /dev/null || pgrep -x kwin_x11 > /dev/null; then
  DE="kde"
  echo "Auto-detected KDE Plasma desktop environment."
else
  DE="kde"
  echo "Could not auto-detect desktop environment. Defaulting to kde."
fi

CONFIG_SOURCE="$REPO_ROOT/keyd/etc/keyd/${DE}.conf"

if [ ! -f "$CONFIG_SOURCE" ]; then
  echo "Error: Could not find keyd config for desktop '$DE' at $CONFIG_SOURCE"
  echo "Usage: sudo ./scripts/update-keyd.sh [kde|niri]"
  exit 1
fi

echo "Installing/updating keyd configuration..."

# Ensure /etc/keyd directory exists
mkdir -p /etc/keyd

# Copy the configuration file from the repository
cp "$CONFIG_SOURCE" /etc/keyd/default.conf
echo "Copied ${DE}.conf to /etc/keyd/default.conf"

# Check if keyd service is active
if systemctl is-active --quiet keyd; then
  echo "keyd service is already running. Reloading configuration..."
  # 'keyd reload' is the native way to apply config changes without restarting the daemon
  keyd reload
  echo "Success! keyd configuration reloaded."
else
  echo "keyd service is not running. Enabling and starting..."
  systemctl enable --now keyd
  echo "Success! keyd service enabled and started."
fi
