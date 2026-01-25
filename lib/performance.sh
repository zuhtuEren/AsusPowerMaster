#!/bin/bash
set_turbo_boost() {
    local state=$1
    local path="/sys/devices/system/cpu/intel_pstate/no_turbo"
    if [ -f "$path" ]; then
        [ "$state" == "on" ] && echo 0 > "$path" && echo "[SUCCESS] Turbo ON"
        [ "$state" == "off" ] && echo 1 > "$path" && echo "[SUCCESS] Turbo OFF"
    else
        echo "[ERROR] Turbo control not found."
    fi
}
