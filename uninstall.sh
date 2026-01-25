#!/bin/bash
# uninstall.sh - Asus Power Master v2.6 Complete Cleanup

[[ $EUID -ne 0 ]] && echo -e "\e[31m[ERROR]\e[0m Please run with sudo." && exit 1

echo "[1/3] Stopping and disabling services..."
for svc in asus-pwr.service asus-pwr-persistence.service; do
    systemctl stop $svc 2>/dev/null
    systemctl disable $svc 2>/dev/null
    rm -f /etc/systemd/system/$svc
done
systemctl daemon-reload

echo "[2/3] Removing files and directories..."
rm -f /usr/local/bin/asus-pwr
rm -rf /usr/local/share/asus-pwr
rm -f /etc/asus-power.conf

echo "[3/3] Cleaning system cache..."
hash -r

echo -e "\n\e[32m[DONE]\e[0m Asus Power Master has been completely removed from the system."
