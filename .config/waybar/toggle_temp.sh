#!/bin/bash
if pgrep -x "gammastep" > /dev/null; then
    pkill gammastep
else
    gammastep -O 10000 &
fi