# zoxide.yazi

A Yazi plugin to integrate zoxide with fzf for directory jumping.

## Usage

Bind a key in `keymap.toml` to run the plugin:

```toml
[[mgr.prepend_keymap]]
on = "<S-z>"
run = "plugin zoxide"
```

Pressing Shift+z will open fzf with zoxide's directory list, select one to cd to it.