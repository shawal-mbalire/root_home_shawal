# if type -q tmux
#     if not test -n "$TMUX"
#         tmux attach-session -t default; or tmux new-session -s default
#     end
# end

if status is-interactive

    set -g -x GTK_THEME BreezeDark

    set fish_greeting ''
    # fastfetch
    fish_vi_key_bindings insert
    set fish_cursor_default block
    set fish_cursor_visual block

    abbr --add vi nvim
    abbr --add vim nvim
    abbr --add gits 'git status'
    abbr --add ll 'ls -la'
    abbr --add gitc 'git commit'
    abbr --add gita 'git add'
    abbr --add gitd 'git diff'
    abbr --add gitl 'git log --oneline'
    abbr --add gitp 'git push'
    abbr --add gitpl 'git pull'
    alias ls='exa --long --header --icons --git'
    alias la='exa -la --header --icons --git'
    alias ll='exa -la --header --icons --git'
    carapace init fish | source

    # Pure prompt color overrides for dark background
    set -g pure_color_primary blue
    set -g pure_color_info cyan
    set -g pure_color_mute white
    set -g pure_color_success green
    set -g pure_color_danger red
    set -g pure_color_warning yellow
end

fish_add_path $HOME/.local/bin
fish_add_path /Users/shawalmbalire/.antigravity/antigravity/bin
