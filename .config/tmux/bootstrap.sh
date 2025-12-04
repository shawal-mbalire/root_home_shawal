#!/usr/bin/env bash

# 12-Factor: Build/Dependency Management
# This script bootstraps the application (tmux config) by installing dependencies.

set -e

CONFIG_DIR="$HOME/.config/tmux"
PLUGINS_DIR="$CONFIG_DIR/plugins"
TPM_DIR="$PLUGINS_DIR/tpm"

echo "Bootstrapping Tmux Configuration..."

# Ensure plugins directory exists
if [ ! -d "$PLUGINS_DIR" ]; then
    echo "Creating plugins directory..."
    mkdir -p "$PLUGINS_DIR"
fi

# Install TPM (Tmux Plugin Manager) if not present
if [ ! -d "$TPM_DIR" ]; then
    echo "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "TPM already installed."
fi

# Install plugins
echo "Installing plugins..."
"$TPM_DIR/bin/install_plugins"

echo "Bootstrap complete. Reload tmux to apply changes (tmux source $CONFIG_DIR/tmux.conf)."
