#!/bin/bash
# lib/battery.sh - Batarya Sağlık Yönetimi

# Bataryanın maksimum şarj seviyesini donanım seviyesinde kısıtlar (Örn: %80)
set_battery_limit() {
    local limit=$1
    if [ -f "$BAT_DIR/charge_control_end_threshold" ]; then
        echo "$limit" | sudo tee "$BAT_DIR/charge_control_end_threshold" > /dev/null
        echo "[SUCCESS] Battery threshold set to $limit%."
    else
        echo "[ERROR] Battery threshold control not supported on this hardware."
    fi
}
