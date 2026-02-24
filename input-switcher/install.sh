#!/bin/bash
set -e

echo "🚀 Installing Input Switcher for macOS..."

# Check if there's macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script only works on macOS"
    exit 1
fi

BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/input-switcher"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$LAUNCH_AGENTS_DIR"

# Check latest version
# TODO


# Install
# TODO

# Verify installation
# TODO

# LaunchAgent configuration
# TODO
