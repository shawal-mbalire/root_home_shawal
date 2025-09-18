if status is-interactive

    set -g -x GTK_THEME 'BreezeDark'

    set fish_greeting ''
    fastfetch
    fish_vi_key_bindings insert
    set fish_cursor_default block
    set fish_cursor_visual block

    abbr --add vi 'nvim'
    abbr --add vim 'nvim'
end
fish_add_path $HOME/.local/bin
