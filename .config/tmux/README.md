# Tmux Configuration (12-Factor Style)

This repository contains a Tmux configuration structured according to [12-Factor App](https://12factor.net/) principles where applicable.

## Principles Applied

1. **Codebase**: One codebase tracked in revision control, many deploys.
2. **Dependencies**: Explicitly declared (via `tpm`) and isolated (installed into `plugins/` which is ignored).
3. **Config**: Configuration that varies between deployments is stored in `tmux.local.conf` (ignored by git).
4. **Build, Release, Run**: The `bootstrap.sh` script handles the "build" (installation of dependencies).

## Installation

1. Clone the repository to `~/.config/tmux`:

   ```bash
   git clone <repo-url> ~/.config/tmux
   ```

2. Run the bootstrap script to install dependencies (TPM and plugins):

   ```bash
   cd ~/.config/tmux
   ./bootstrap.sh
   ```

3. Start Tmux:

   ```bash
   tmux
   ```

## Local Configuration

To apply machine-specific settings (e.g., different prefix, colors, or paths) without modifying the main `tmux.conf`:

1. Copy the example file:

   ```bash
   cp tmux.local.conf.example tmux.local.conf
   ```

2. Edit `tmux.local.conf`.
3. Reload Tmux (`<prefix> I` or `tmux source ~/.config/tmux/tmux.conf`).

## Directory Structure

* `tmux.conf`: Main configuration file (entry point).
* `conf/`: Modular configuration files.
  * `opts.conf`: General options.
  * `keybinds.conf`: Key bindings.
  * `skin.conf`: Theme settings.
  * `plugins.conf`: Plugin list and settings.
* `bootstrap.sh`: Script to install dependencies.
* `plugins/`: Directory for installed plugins (ignored by git).
* `tmux.local.conf`: Local overrides (ignored by git).
