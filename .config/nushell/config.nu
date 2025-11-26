def create_left_prompt [] {
    $"(ansi cyan)($env.PWD)(ansi reset) ❯ "
}

$env.config = {
    buffer_editor: "nvim",
    show_banner: false,
}

alias vim = nvim
alias vi = nvim
alias ll = ls -l 
alias la = ls -la
