#!/bin/bash
# Asus Power Master - Ana Kontrol Dosyası v2.6 (Final Gold)

# --- KÜTÜPHANE YÜKLEME ---
# Kütüphane dosyalarını sistem klasöründe veya yerel 'lib' içinde arar
if [ -d "/usr/local/share/asus-pwr/lib" ]; then
    LIB_DIR="/usr/local/share/asus-pwr/lib"
else
    LIB_DIR="$(dirname "$(readlink -f "$0")")/lib"
fi

for lib in extra battery performance dashboard persistence; do
    if [ -f "$LIB_DIR/$lib.sh" ]; then 
        source "$LIB_DIR/$lib.sh"
    else 
        echo "[ERROR] $lib.sh missing!"; exit 1 
    fi
done

# --- GÖZCÜ (WATCHDOG) MOTORU ---
# Güç kaynağı değişimlerini 2 saniyede bir kontrol eden ana döngü
monitor_ac_status() {
    local kbd_pref="$1"
    echo -e "\e[34m[INFO]\e[0m Smart Watchdog active. Monitoring power states..."
    local last_status=""

    while true; do
        # Kullanıcı ayarlarını her döngüde dosyadan tazeler (Anlık tepki için)
        [ -f "/etc/asus-power.conf" ] && source "/etc/asus-power.conf"
        
        local current_status=$(get_ac_status)
        if [ "$current_status" != "$last_status" ]; then
            apply_auto_profile "$kbd_pref"
            last_status=$current_status
        fi
        sleep 2
    done
}

# --- YETKİ KONTROLÜ ---
[[ $EUID -ne 0 ]] && echo -e "\e[31m[ERROR]\e[0m Root privileges required. Please use sudo." && exit 1

# --- KOMUT YÖNLENDİRME ---
case $1 in
    -s|--status)   show_dashboard ;;
    -b|--battery)  set_battery_limit "$2"; [[ "$3" == "-p" ]] && save_setting "BATTERY_LIMIT" "$2" && enable_persistence ;;
    -t|--turbo)    set_turbo_boost "$2";  [[ "$3" == "-p" ]] && save_setting "TURBO_BOOST" "$2" && enable_persistence ;;
    -f|--fan)      set_fan_mode "$2";     [[ "$3" == "-p" ]] && save_setting "FAN_MODE" "$2" && enable_persistence ;;
    -k|--keyboard) set_kbd_brightness "$2" ;;
    
    --set-ac|--set-bat)
        # Profil tipini (AC/BAT) tespit eder
        if [[ "$1" == "--set-ac" ]]; then profile_type="AC"; else profile_type="BAT"; fi
        shift
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                -f|--fan)      save_setting "${profile_type}_FAN" "$2"; shift ;;
                -t|--turbo)    save_setting "${profile_type}_TURBO" "$2"; shift ;;
                -k|--keyboard) save_setting "${profile_type}_KBD" "$2"; shift ;;
            esac
            shift
        done
        enable_persistence
        echo -e "\e[32m[SUCCESS]\e[0m $profile_type profile updated in /etc/asus-power.conf"
        ;;

    --monitor)
        # Mevcut parlaklığı al veya parametreyle başlat
        kbd_arg=$(cat "$KBD_PATH/brightness" 2>/dev/null || echo 0)
        [[ "$2" == "-k" ]] && kbd_arg="$3"
        monitor_ac_status "$kbd_arg"
        ;;

    --apply)
        # Sistem açılışında kaydedilen ayarları uygular
        [ -f "/etc/asus-power.conf" ] && source "/etc/asus-power.conf"
        [[ -n "$BATTERY_LIMIT" ]] && set_battery_limit "$BATTERY_LIMIT"
        [[ -n "$TURBO_BOOST" ]] && set_turbo_boost "$TURBO_BOOST"
        [[ -n "$FAN_MODE" ]] && set_fan_mode "$FAN_MODE"
        ;;

    -h|--help|*)
        echo -e "\e[34mAsus Power Master v2.6 - Usage Guide\e[0m"
        echo "-------------------------------------------------------"
        echo "  -s, --status              Show dashboard status"
        echo "  -b, --battery [60-100]    Set charge limit (-p for persistence)"
        echo "  -t, --turbo [on/off]      Toggle CPU Turbo (-p for persistence)"
        echo "  -f, --fan [0|1|2]         Set Fan Mode (0:Bal, 1:Turbo, 2:Sil)"
        echo "  -k, --keyboard [0-3]      Set Backlight level"
        echo ""
        echo -e "\e[1mPROFILE MANAGEMENT:\e[0m"
        echo "  --set-ac [options]        Customize AC (Plugged) profile"
        echo "  --set-bat [options]       Customize Battery profile"
        echo "  --monitor [-k level]      Start smart background watchdog"
        ;;
esac
