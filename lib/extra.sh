#!/bin/bash
# Asus Power Master v2 - Universal Discovery

# --- GLOBAL PATH DISCOVERY ---
export KBD_PATH=$(find /sys/class/leds/ -name "*kbd_backlight" | head -n 1)
export BAT_DIR=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)
export AC_PATH=$(find /sys/class/power_supply/ -name "AC*" -o -name "ADP*" | head -n 1)
export FAN_PATH=$(find /sys/devices/platform/ -name "throttle_thermal_policy" -o -name "fan_boost_mode" | head -n 1)
export KBD_MAX_BRIGHTNESS=$( [ -f "$KBD_PATH/max_brightness" ] && cat "$KBD_PATH/max_brightness" || echo 3 )

set_fan_mode() {
    local mode="${1:-0}"
    
    if [ -n "$FAN_PATH" ] && [ -f "$FAN_PATH" ]; then
        # Sadece izin verilen modları kontrol et (0, 1, 2)
        if [[ "$mode" =~ ^[0-2]$ ]]; then
            echo "$mode" | sudo tee "$FAN_PATH" > /dev/null
            
            case $mode in
                0) echo -e "\e[32m[SUCCESS]\e[0m Fan Mode: Balanced" ;;
                1) echo -e "\e[31m[SUCCESS]\e[0m Fan Mode: Overboost (Turbo)" ;;
                2) echo -e "\e[36m[SUCCESS]\e[0m Fan Mode: Silent" ;;
            esac
        else
            echo -e "\e[31m[ERROR]\e[0m Invalid mode. Use 0 (Balanced), 1 (Overboost), or 2 (Silent)."
        fi
    else
        echo -e "\e[33m[WARN]\e[0m Fan control interface not found on this system."
    fi
}

get_ac_status() {
    if [ -f "$AC_PATH/online" ]; then
        cat "$AC_PATH/online"
    else
        echo "1" # Bulamazsa güvenlik için AC varsay
    fi
}

apply_auto_profile() {
    # 1. Konfigürasyonu yükle
    [ -f "/etc/asus-power.conf" ] && source "/etc/asus-power.conf"
    
    local status=$(get_ac_status)
    local kbd_monitor_pref="$1" # Monitörden gelen (servis veya manuel) değer

    if [ "$status" == "1" ]; then
        echo -e "\e[32m[EVENT]\e[0m AC Power Connected."
        
        # ÖNCELİK SIRALAMASI: 
        # 1. Konfigürasyon Dosyası (AC_KBD)
        # 2. Monitör Parametresi (kbd_monitor_pref)
        # 3. Donanım Maksimumu ($KBD_MAX_BRIGHTNESS)
        local final_kbd="${AC_KBD:-${kbd_monitor_pref:-$KBD_MAX_BRIGHTNESS}}"
        
        set_turbo_boost "${AC_TURBO:-on}"
        set_kbd_brightness "$final_kbd"
        set_fan_mode "${AC_FAN:-1}"
    else
        echo -e "\e[33m[EVENT]\e[0m Battery Detected."
        
        # Pilde de aynı öncelik: Dosya > Monitör > 0
        local final_kbd="${BAT_KBD:-${kbd_monitor_pref:-0}}"
        
        set_turbo_boost "${BAT_TURBO:-off}"
        set_kbd_brightness "$final_kbd"
        set_fan_mode "${BAT_FAN:-2}"
    fi
}

set_kbd_brightness() {
    local level=$1
    if [ -n "$KBD_PATH" ]; then
        echo "$level" | sudo tee "$KBD_PATH/brightness" > /dev/null
        echo "[SUCCESS] Keyboard backlight set to $level."
    fi
}

get_wattage() {
    local watt_final="0.00"
    if [ -f "$BAT_DIR/power_now" ]; then
        local p_now=$(cat "$BAT_DIR/power_now")
        # Negatif değerleri (şarj olurken) pozitife çevir
        [ $p_now -lt 0 ] && p_now=$((p_now * -1))
        local w_int=$(( p_now / 1000000 ))
        local w_dec=$(( (p_now % 1000000) / 10000 ))
        watt_final=$(printf "%d.%02d" "$w_int" "$w_dec")
    fi
    echo "$watt_final"
}
