#!/usr/bin/env bash
set -e

# Make sure we're running as root for system-level changes
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo ./scripts/update-keyd.sh)"
  exit 1
fi

# Get the absolute path to the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SOURCE="$REPO_ROOT/keyd/etc/keyd/default.conf"

if [ ! -f "$CONFIG_SOURCE" ]; then
  echo "Error: Could not find keyd config at $CONFIG_SOURCE"
  exit 1
fi

echo "Installing/updating keyd configuration..."

# Ensure /etc/keyd directory exists
mkdir -p /etc/keyd

# Copy the configuration file from the repository
cp "$CONFIG_SOURCE" /etc/keyd/default.conf
echo "Copied default.conf to /etc/keyd/default.conf"

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
