#!/bin/bash
# Asus Power Master - Complete Uninstaller v2.6

[[ $EUID -ne 0 ]] && echo -e "\e[31m[ERROR]\e[0m Please run as root (sudo)." && exit 1

echo -e "\e[34m[1/4]\e[0m Stopping system services..."
systemctl stop asus-pwr.service 2>/dev/null
systemctl disable asus-pwr.service 2>/dev/null
systemctl stop asus-pwr-persistence.service 2>/dev/null
systemctl disable asus-pwr-persistence.service 2>/dev/null

echo -e "\e[34m[2/4]\e[0m Removing system files..."
rm -f /usr/local/bin/asus-pwr
rm -rf /usr/local/share/asus-pwr/
rm -f /etc/systemd/system/asus-pwr.service
rm -f /etc/systemd/system/asus-pwr-persistence.service

echo -e "\e[34m[3/4]\e[0m Cleaning up configuration files..."
rm -f /etc/asus-power.conf 

echo -e "\e[34m[4/4]\e[0m Reloading system daemons..."
systemctl daemon-reload

echo -e "\n\e[32m[DONE]\e[0m Asus Power Master has been completely removed from your system."
