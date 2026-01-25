#!/bin/bash
# uninstall.sh - Asus Power Master v2.6 Complete Cleanup

[[ $EUID -ne 0 ]] && echo -e "\e[31m[ERROR]\e[0m Lütfen sudo ile çalıştırın." && exit 1

echo "[1/3] Servisler durduruluyor ve devre dışı bırakılıyor..."
# Döngü ile her iki olası servisi de temizliyoruz
for svc in asus-pwr.service asus-pwr-persistence.service; do
    systemctl stop $svc 2>/dev/null
    systemctl disable $svc 2>/dev/null
    rm -f /etc/systemd/system/$svc
done
systemctl daemon-reload

echo "[2/3] Dosya ve dizinler kaldırılıyor..."
rm -f /usr/local/bin/asus-pwr
rm -rf /usr/local/share/asus-pwr
rm -f /etc/asus-power.conf

echo "[3/3] Sistem önbelleği temizleniyor..."
hash -r

echo -e "\n\e[32m[DONE]\e[0m Asus Power Master sistemden tamamen kaldırıldı."
