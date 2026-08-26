#!/bin/bash
# Fedora-specific setup for stow'd dotfiles

# Generate tool init files for nushell
mkdir -p ~/.cache/{carapace,starship}

carapace init nu > ~/.cache/carapace/init.nu
starship init nu > ~/.cache/starship/init.nu
mkdir -p ~/.local/share/atuin
atuin init nu > ~/.local/share/atuin/init.nu
