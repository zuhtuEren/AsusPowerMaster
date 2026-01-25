#!/bin/bash
# install.sh - Asus Power Master v2.6

# Root kontrolü (En başta yetki kontrolü yapmak profesyonelliktir)
[[ $EUID -ne 0 ]] && echo -e "\e[31m[ERROR]\e[0m Lütfen sudo ile çalıştırın." && exit 1

# Dosya kontrolü
if [ ! -f "asus-pwr.service" ]; then
    echo -e "\e[31m[ERROR]\e[0m asus-pwr.service dosyası bulunamadı!"
    exit 1
fi

echo "[1/4] Sistem dosyaları yükleniyor..."
mkdir -p /usr/local/share/asus-pwr/lib
cp -r lib/* /usr/local/share/asus-pwr/lib/
cp main.sh /usr/local/bin/asus-pwr
chmod +x /usr/local/bin/asus-pwr

echo "[2/4] Systemd servisi yapılandırılıyor..."
cp asus-pwr.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable asus-pwr.service

echo "[3/4] Servis başlatılıyor..."
systemctl restart asus-pwr.service

echo "[4/4] Kabuk (Shell) yenileniyor..."
hash -r

echo -e "\n\e[32m[DONE]\e[0m Asus Power Master v2.6 başarıyla kuruldu ve arka planda çalışıyor!"
