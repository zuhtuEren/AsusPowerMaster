#!/bin/bash
# Asus Power Master - Universal CLI v2.6 (Final)

# --- PATH DISCOVERY ---
if [ -d "/usr/local/share/asus-pwr/lib" ]; then
    LIB_DIR="/usr/local/share/asus-pwr/lib"
else
    LIB_DIR="$(dirname "$(readlink -f "$0")")/lib"
fi

# --- LOAD LIBRARIES ---
for lib in extra battery performance dashboard persistence; do
    if [ -f "$LIB_DIR/$lib.sh" ]; then source "$LIB_DIR/$lib.sh"; else echo "[ERROR] $lib.sh missing!"; exit 1; fi
done

monitor_ac_status() {
    local kbd_pref="$1"
    echo -e "\e[34m[INFO]\e[0m Smart Watchdog started."
    local last_status=""

    while true; do
        # HER DÖNGÜDE DOSYAYI YENİDEN OKU
        [ -f "/etc/asus-power.conf" ] && source "/etc/asus-power.conf"
        
        local current_status=$(get_ac_status)
        if [ "$current_status" != "$last_status" ]; then
            apply_auto_profile "$kbd_pref"
            last_status=$current_status
        fi
        sleep 2
    done
}

[[ $EUID -ne 0 ]] && echo -e "\e[31m[ERROR]\e[0m Lütfen sudo ile çalıştırın!" && exit 1

case $1 in
    -s|--status)   show_dashboard ;;
    -b|--battery)  set_battery_limit "$2"; [[ "$3" == "-p" ]] && save_setting "BATTERY_LIMIT" "$2" && enable_persistence ;;
    -t|--turbo)    set_turbo_boost "$2";  [[ "$3" == "-p" ]] && save_setting "TURBO_BOOST" "$2" && enable_persistence ;;
    -f|--fan)      set_fan_mode "$2";     [[ "$3" == "-p" ]] && save_setting "FAN_MODE" "$2" && enable_persistence ;;
    -k|--keyboard) set_kbd_brightness "$2" ;;
    
    --set-ac|--set-bat)
        # Daha güvenli profil tespiti
        if [[ "$1" == "--set-ac" ]]; then profile_type="AC"; else profile_type="BAT"; fi
        shift
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                -f|--fan) save_setting "${profile_type}_FAN" "$2"; shift ;;
                -t|--turbo) save_setting "${profile_type}_TURBO" "$2"; shift ;;
                -k|--keyboard) save_setting "${profile_type}_KBD" "$2"; shift ;;
            esac
            shift
        done
        enable_persistence
        echo -e "\e[32m[SUCCESS]\e[0m $profile_type profile updated in /etc/asus-power.conf"
        ;;

    --monitor)
        # Mevcut parlaklığı varsayılan al, parametre varsa ez
        kbd_arg=$(cat "$KBD_PATH/brightness" 2>/dev/null || echo 0)
        [[ "$2" == "-k" ]] && kbd_arg="$3"
        monitor_ac_status "$kbd_arg"
        ;;

    --apply)
        [ -f "/etc/asus-power.conf" ] && source "/etc/asus-power.conf"
        [[ -n "$BATTERY_LIMIT" ]] && set_battery_limit "$BATTERY_LIMIT"
        [[ -n "$TURBO_BOOST" ]] && set_turbo_boost "$TURBO_BOOST"
        [[ -n "$FAN_MODE" ]] && set_fan_mode "$FAN_MODE"
        ;;

    -h|--help|*)
        echo -e "\e[34mAsus Power Master v2.6 - Usage Guide\e[0m"
        echo "-------------------------------------------------------"
        echo -e "\e[1mCORE COMMANDS:\e[0m"
        echo "  -s, --status              Show dashboard"
        echo "  -b, --battery [60-100]    Set charge limit (-p for persistence)"
        echo "  -t, --turbo [on/off]      Toggle Turbo Boost (-p for persistence)"
        echo "  -f, --fan [0|1|2]         Set Fan Mode (0:Bal, 1:Turbo, 2:Sil)"
        echo "  -k, --keyboard [0-3]      Set Backlight level"
        echo ""
        echo -e "\e[1mPROFILE MANAGEMENT (For Watchdog):\e[0m"
        echo "  --set-ac [options]        Customize AC profile"
        echo "  --set-bat [options]       Customize Battery profile"
        echo "  --monitor [-k val]        Start smart watchdog"
        echo ""
        echo -e "\e[1mEXAMPLE:\e[0m sudo asus-pwr --set-bat -f 0 -t off"
        ;;
esac
