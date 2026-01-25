#!/bin/bash
# lib/performance.sh - System State Control Module

# Control Keyboard Brightness
set_kbd_brightness() {
    local level=$1
    if [ -n "$KBD_PATH" ]; then
        echo "$level" | sudo tee "$KBD_PATH/brightness" > /dev/null
        echo -e "[SUCCESS] Keyboard backlight set to: \e[34m$level\e[0m"
    else
        echo -e "\e[33m[WARN]\e[0m Keyboard backlight interface not found."
    fi
}

# Control Fan Mode
set_fan_mode() {
    local mode="${1:-0}"
    if [ -n "$FAN_PATH" ] && [ -f "$FAN_PATH" ]; then
        if [[ "$mode" =~ ^[0-2]$ ]]; then
            echo "$mode" | sudo tee "$FAN_PATH" > /dev/null
            case $mode in
                0) label="Balanced" ;;
                1) label="Overboost" ;;
                2) label="Silent" ;;
            esac
            echo -e "[SUCCESS] Fan Mode set to: \e[34m$label\e[0m"
        else
            echo -e "\e[31m[ERROR]\e[0m Invalid Fan Mode (0-2)."
        fi
    fi
}

# Control CPU Turbo
set_turbo_boost() {
    local state=$1
    local path="/sys/devices/system/cpu/intel_pstate/no_turbo"
    if [ -f "$path" ]; then
        if [[ "$state" == "on" ]]; then
            echo 0 > "$path"
            echo -e "[SUCCESS] Turbo Boost: \e[32mENABLED\e[0m"
        else
            echo 1 > "$path"
            echo -e "[SUCCESS] Turbo Boost: \e[31mDISABLED\e[0m"
        fi
    fi
}

# Automated Profile Application
apply_auto_profile() {
    local kbd_pref="$1"
    local ac_state=$(get_ac_status)

    if [ "$ac_state" == "1" ]; then
        echo -e "\e[32m[EVENT]\e[0m AC Power Connected. Applying Performance Profile..."
        set_fan_mode "${AC_FAN:-1}"
        set_turbo_boost "${AC_TURBO:-on}"
        set_kbd_brightness "${AC_KBD:-$kbd_pref}"
    else
        echo -e "\e[33m[EVENT]\e[0m Battery Detected. Applying Power Save Profile..."
        set_fan_mode "${BAT_FAN:-2}"
        set_turbo_boost "${BAT_TURBO:-off}"
        set_kbd_brightness "${BAT_KBD:-0}"
    fi
}
