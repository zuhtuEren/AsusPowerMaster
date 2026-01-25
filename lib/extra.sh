#!/bin/bash
# lib/extra.sh - Hardware Path Discovery Module

# --- GLOBAL PATH DISCOVERY ---
export KBD_PATH=$(find /sys/class/leds/ -name "*kbd_backlight" | head -n 1)
export BAT_DIR=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)
export AC_PATH=$(find /sys/class/power_supply/ -name "AC*" -o -name "ADP*" | head -n 1)
export FAN_PATH=$(find /sys/devices/platform/ -name "throttle_thermal_policy" -o -name "fan_boost_mode" | head -n 1)
export KBD_MAX_BRIGHTNESS=$( [ -f "$KBD_PATH/max_brightness" ] && cat "$KBD_PATH/max_brightness" || echo 3 )

# Helper to check AC status (Returns 1 for AC, 0 for Battery)
get_ac_status() {
    [ -f "$AC_PATH/online" ] && cat "$AC_PATH/online" || echo "1"
}

# Helper to calculate battery discharge/charge rate
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

