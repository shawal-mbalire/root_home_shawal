#!/bin/bash
# macOS-specific setup for stow'd dotfiles

# Nushell on macOS uses ~/Library/Application Support/nushell/
# instead of ~/.config/nushell/. Symlink so stow works.
if [[ "$(uname)" == "Darwin" ]]; then
    NUGHELL_APP_SUPPORT="$HOME/Library/Application Support/nushell"
    if [[ ! -L "$NUGHELL_APP_SUPPORT" ]]; then
        rm -rf "$NUGHELL_APP_SUPPORT"
        ln -s "$HOME/.config/nushell" "$NUGHELL_APP_SUPPORT"
        echo "Symlinked nushell config"
    fi
fi
