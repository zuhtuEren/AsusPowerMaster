#!/bin/bash
# battery.sh - Uses discovery from extra.sh

set_battery_limit() {
    local limit=$1
    # extra.sh içindeki BAT_DIR değişkenini kullanıyoruz
    if [ -f "$BAT_DIR/charge_control_end_threshold" ]; then
        echo "$limit" | sudo tee "$BAT_DIR/charge_control_end_threshold" > /dev/null
        echo "[SUCCESS] Battery threshold set to $limit%."
    else
        echo "[ERROR] Battery threshold control not supported on this hardware."
    fi
}
