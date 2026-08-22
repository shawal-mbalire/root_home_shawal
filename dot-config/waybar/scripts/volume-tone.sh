#!/bin/bash

# Volume feedback tone script
# Plays a short beep when volume changes

SOUND="/usr/share/sounds/alsa/Front_Center.wav"

if [ ! -f "$SOUND" ]; then
    exit 0
fi

# Only play if pw-play is available
if command -v pw-play &> /dev/null; then
    pw-play --volume=0.3 "$SOUND" 2>/dev/null &
fi
