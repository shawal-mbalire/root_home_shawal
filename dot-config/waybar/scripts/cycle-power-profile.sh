#!/bin/bash

current=$(tuned-adm active 2>/dev/null | awk '/Current active profile:/ {print $NF}')

if [ -z "$current" ]; then
    notify-send "Power Profile" "Error: Could not get current profile"
    exit 1
fi

case $current in
    powersave) next="balanced" ;;
    balanced) next="throughput-performance" ;;
    throughput-performance) next="powersave" ;;
    *) next="balanced" ;;
esac

if tuned-adm profile "$next" 2>/dev/null; then
    notify-send "Power Profile" "Switched to: $next"
else
    notify-send "Power Profile" "Error: Failed to switch profile"
    exit 1
fi
