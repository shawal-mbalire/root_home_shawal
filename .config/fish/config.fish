# if type -q tmux
#     if not test -n "$TMUX"
#         tmux attach-session -t default; or tmux new-session -s default
#     end
# end

if status is-interactive

    set -g -x GTK_THEME BreezeDark

    set fish_greeting ''
    fastfetch
    fish_vi_key_bindings insert
    set fish_cursor_default block
    set fish_cursor_visual block

    abbr --add vi nvim
    abbr --add vim nvim
end
fish_add_path $HOME/.local/bin
# eval "$(/opt/homebrew/bin/brew shellenv)"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
