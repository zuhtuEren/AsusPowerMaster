#!/bin/bash
# lib/performance.sh - Dynamic Performance Module

# Turbo Boost Kontrolü
set_turbo_boost() {
    local state=$1
    local path="/sys/devices/system/cpu/intel_pstate/no_turbo"
    if [ -f "$path" ]; then
        [[ "$state" == "on" ]] && echo 0 > "$path" && echo -e "[SUCCESS] Turbo \e[32mON\e[0m"
        [[ "$state" == "off" ]] && echo 1 > "$path" && echo -e "[SUCCESS] Turbo \e[31mOFF\e[0m"
    fi
}

# Fan Modu Kontrolü
set_fan_mode() {
    local mode=$1
    if [ -f "$FAN_PATH" ]; then
        echo "$mode" > "$FAN_PATH"
        case $mode in
            0) label="Balanced" ;;
            1) label="Overboost" ;;
            2) label="Silent" ;;
        esac
        echo -e "[SUCCESS] Fan Mode: \e[34m$label\e[0m"
    fi
}

# AC (Priz) Profilini Uygula
apply_ac_profile() {
    local kbd_pref="${1:-2}" # Parametre yoksa varsayılan 2
    set_fan_mode "${AC_FAN:-1}"
    set_turbo_boost "${AC_TURBO:-on}"
    set_kbd_brightness "${AC_KBD:-$kbd_pref}"
}

# Battery (Pil) Profilini Uygula
apply_bat_profile() {
    local kbd_pref="${1:-0}" # Parametre yoksa varsayılan 0
    set_fan_mode "${BAT_FAN:-2}"
    set_turbo_boost "${BAT_TURBO:-off}"
    set_kbd_brightness "${BAT_KBD:-$kbd_pref}"
}

# Ana Otomasyon Fonksiyonu
apply_auto_profile() {
    local kbd_pref="$1"
    local ac_state=$(get_ac_status)

    if [ "$ac_state" == "1" ]; then
        echo -e "\e[32m[EVENT]\e[0m AC Power Connected."
        apply_ac_profile "$kbd_pref"
    else
        echo -e "\e[33m[EVENT]\e[0m Battery Detected."
        apply_bat_profile "$kbd_pref"
    fi
}
