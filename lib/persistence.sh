#!/bin/bash
# persistence.sh - Unified naming

save_setting() {
    local key=$1; local val=$2
    [ ! -f "/etc/asus-power.conf" ] && sudo touch "/etc/asus-power.conf"
    if grep -q "^$key=" "/etc/asus-power.conf"; then
        sudo sed -i "s/^$key=.*/$key=$val/" "/etc/asus-power.conf"
    else
        echo "$key=$val" | sudo tee -a "/etc/asus-power.conf" > /dev/null
    fi
}

enable_persistence() {
    # Ismi asus-pwr-persistence.service yapalım ki ana servisle karışmasın
    local SERVICE_FILE="/etc/systemd/system/asus-pwr-persistence.service"
    if [ ! -f "$SERVICE_FILE" ]; then
        sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Asus Power Master Boot Persistence
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/asus-pwr --apply
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl daemon-reload
        sudo systemctl enable asus-pwr-persistence.service
        echo "[SUCCESS] Boot persistence enabled."
    fi
}
