#!/bin/bash
# install.sh - Asus Power Master v2.6

# Root check
[[ $EUID -ne 0 ]] && echo -e "\e[31m[ERROR]\e[0m Please run with sudo." && exit 1

# File integrity check
if [ ! -f "asus-pwr.service" ]; then
    echo -e "\e[31m[ERROR]\e[0m asus-pwr.service file not found in current directory!"
    exit 1
fi

echo "[1/4] Installing system files..."
mkdir -p /usr/local/share/asus-pwr/lib
cp -r lib/* /usr/local/share/asus-pwr/lib/
cp main.sh /usr/local/bin/asus-pwr
chmod +x /usr/local/bin/asus-pwr

echo "[2/4] Configuring Systemd service..."
cp asus-pwr.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable asus-pwr.service

echo "[3/4] Starting service..."
systemctl restart asus-pwr.service

echo "[4/4] Refreshing shell environment..."
hash -r

echo -e "\n\e[32m[DONE]\e[0m Asus Power Master v2.6 installed successfully and is running in the background!"
