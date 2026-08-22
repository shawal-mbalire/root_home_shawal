# Waybar Configuration

Catppuccin Mocha themed waybar with pill-style modules and 1px borders.

## Install Dependencies (Fedora)

```bash
sudo dnf install waybar jetbrains-mono-fonts sono-fonts brightnessctl grimblast wireplumber pipewire-utils
```

### Optional Dependencies

- **Screenshots**: `grimblast` (from AUR or COPR)
- **Terminal**: `kitty`
- **Network**: `network-manager-applet` (for `nm-connection-editor`)
- **Power Management**: `tuned-ppd` (uses `tuned-adm` under the hood)
- **Bluetooth**: `bluez` + `bluez-tools`
- **Audio**: `pipewire` + `wireplumber` (uses `wpctl`)

## Scripts

All scripts are in `scripts/`:

| Script | Purpose |
|---|---|
| `bluetooth.sh` | Bluetooth device menu and power toggle |
| `cycle-power-profile.sh` | Cycle through tuned-ppd profiles |
| `select-audio-device.sh` | Audio device selector (rofi) |
| `select-power-profile.sh` | Power profile selector (rofi) |
| `toggle_temp.sh` | Toggle gammastep (night light) |
| `volume-control.sh` | Volume control with feedback tone |
| `volume-tone.sh` | Play volume feedback tone |

## Volume Feedback Tone

The volume keys play a short beep using PipeWire. Sound file used:

```
/usr/share/sounds/alsa/Front_Center.wav
```

If the file doesn't exist on your system, check:
- `/usr/share/sounds/alsa/`
- `/usr/share/sounds/freedesktop/`
- `/usr/share/sounds/gnome/`

Update the `SOUND` variable in `scripts/volume-control.sh` to use a different file.

## Reload Waybar

```bash
killall waybar && waybar &
```
