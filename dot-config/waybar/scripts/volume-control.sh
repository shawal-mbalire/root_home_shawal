#!/bin/bash

# Volume control with feedback tone
# Usage: volume-control.sh {up|down|mute}

SOUND="/usr/share/sounds/alsa/Front_Center.wav"
STEP="5%"

case "${1:-}" in
    up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${STEP}+"
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${STEP}-"
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    *)
        echo "Usage: $0 {up|down|mute}" >&2
        exit 1
        ;;
esac

# Get current volume for notification
VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2 * 100)}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q "MUTED" && echo "yes" || echo "no")

if [ "$MUTED" = "yes" ]; then
    notify-send -a "volume" -u low -h int:value:0 " 󰝟 Muted" -t 1000
else
    notify-send -a "volume" -u low -h int:value:"$VOL" " 󰎈 Volume: ${VOL}%" -t 1000
fi

# Play feedback tone
if command -v pw-play &> /dev/null && [ -f "$SOUND" ]; then
    pw-play --volume=0.3 "$SOUND" 2>/dev/null &
fi
