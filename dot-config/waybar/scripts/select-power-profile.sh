#!/bin/bash

PROFILES=(
    "powersave|󰾆 Low power consumption"
    "balanced|󰝇 General purpose"
    "balanced-battery|󰁼 Battery optimized"
    "desktop|󰘚 Desktop use case"
    "throughput-performance|󰓅 General performance"
    "accelerator-performance|󰓈 Accelerator performance"
    "latency-performance|󰀠 Low latency"
)

CURRENT=$(tuned-adm active 2>/dev/null | awk '/Current active profile:/ {print $NF}')

if [ -z "$CURRENT" ]; then
    notify-send "Power Profile" "Error: Could not get current profile"
    exit 1
fi

MENU=""
for entry in "${PROFILES[@]}"; do
    IFS='|' read -r name desc <<< "$entry"
    if [ "$name" = "$CURRENT" ]; then
        MENU="${MENU}${desc}  ✓\n"
    else
        MENU="${MENU}${desc}\n"
    fi
done

CHOSEN=$(echo -e "$MENU" | rofi -dmenu -p "Power Profile" -i -theme "$HOME/.config/rofi/themes/waybar-menu.rasi" 2>/dev/null)

if [ -n "$CHOSEN" ]; then
    CHOSEN_CLEAN=$(echo "$CHOSEN" | sed 's/  ✓$//')
    for entry in "${PROFILES[@]}"; do
        IFS='|' read -r name desc <<< "$entry"
        if [ "$desc" = "$CHOSEN_CLEAN" ]; then
            if tuned-adm profile "$name" 2>/dev/null; then
                notify-send "Power Profile" "Switched to: $desc"
            else
                notify-send "Power Profile" "Error: Failed to switch to $desc"
                exit 1
            fi
            break
        fi
    done
fi
