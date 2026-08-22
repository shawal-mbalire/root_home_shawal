#!/bin/bash

if pgrep -x "gammastep" > /dev/null; then
    echo '{"text":"󰔏 On","tooltip":"Gammastep active (click to disable)"}'
else
    echo '{"text":"󰔏 Off","tooltip":"Gammastep inactive (click to enable)"}'
fi
