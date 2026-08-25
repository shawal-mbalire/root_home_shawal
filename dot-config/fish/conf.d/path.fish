# PATH Management
# Centralized PATH configuration for easy git tracking

# Homebrew (macOS)
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# User local binaries
test -d $HOME/.local/bin; and fish_add_path $HOME/.local/bin

# Bun runtime
set -q BUN_INSTALL; or set -gx BUN_INSTALL "$HOME/.bun"
test -d $BUN_INSTALL/bin; and fish_add_path $BUN_INSTALL/bin

# OpenCode
test -d $HOME/.opencode/bin; and fish_add_path $HOME/.opencode/bin

# LM Studio CLI
test -d $HOME/.lmstudio/bin; and fish_add_path $HOME/.lmstudio/bin

# Google Cloud SDK
if test -f $HOME/google-cloud-sdk/path.fish.inc
    source $HOME/google-cloud-sdk/path.fish.inc
end
