#!/bin/bash
# lib/extra.sh - Donanım Yolu Keşif Modülü

# Sistemdeki klavye ışığı, batarya ve fan kontrol yollarını otomatik bulur
export KBD_PATH=$(find /sys/class/leds/ -name "*kbd_backlight" | head -n 1)
export BAT_DIR=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)
export AC_PATH=$(find /sys/class/power_supply/ -name "AC*" -o -name "ADP*" | head -n 1)
export FAN_PATH=$(find /sys/devices/platform/ -name "throttle_thermal_policy" -o -name "fan_boost_mode" | head -n 1)
export KBD_MAX_BRIGHTNESS=$( [ -f "$KBD_PATH/max_brightness" ] && cat "$KBD_PATH/max_brightness" || echo 3 )

# AC adaptörün durumunu sorgular (1: Takılı, 0: Pilde)
get_ac_status() {
    [ -f "$AC_PATH/online" ] && cat "$AC_PATH/online" || echo "1"
}

# Batarya tüketimini Watt cinsinden hesaplar
get_wattage() {
    local watt_final="0.00"
    if [ -f "$BAT_DIR/power_now" ]; then
        local p_now=$(cat "$BAT_DIR/power_now")
        [ $p_now -lt 0 ] && p_now=$((p_now * -1))
        local w_int=$(( p_now / 1000000 ))
        local w_dec=$(( (p_now % 1000000) / 10000 ))
        watt_final=$(printf "%d.%02d" "$w_int" "$w_dec")
    fi
    echo "$watt_final"
}
