#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CHR_VERSION="7.12"
CHR_FILE="chr-${CHR_VERSION}.img"
CHR_ZIP="${CHR_FILE}.zip"
CHR_URL="https://download.mikrotik.com/routeros/${CHR_VERSION}/${CHR_ZIP}"

echo -e "${CYAN}"
echo "=============================================="
echo "   MikroTik CHR Installer v${CHR_VERSION}"
echo "   File Resmi dari MikroTik"
echo "=============================================="
echo -e "${NC}"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] Script harus dijalankan sebagai root!${NC}"
   exit 1
fi

echo -e "${YELLOW}[INFO] Mendeteksi disk utama...${NC}"
DISK=$(lsblk -d -o NAME,TYPE | grep disk | awk '{print $1}' | head -n1)
DISK_PATH="/dev/${DISK}"
echo -e "${GREEN}[OK] Disk ditemukan: ${DISK_PATH}${NC}"

echo ""
echo -e "${RED}=============================================="
echo " PERINGATAN !!!"
echo " Semua data di ${DISK_PATH} akan TERHAPUS!"
echo " Pastikan kamu punya akses VNC/Console!"
echo -e "==============================================${NC}"
echo ""
read -p "Ketik 'yes' untuk lanjut: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo -e "${YELLOW}Instalasi dibatalkan.${NC}"
    exit 0
fi

echo -e "${YELLOW}[INFO] Menginstall dependencies...${NC}"
apt-get update -qq
apt-get install -y wget unzip

echo -e "${YELLOW}[INFO] Downloading CHR ${CHR_VERSION} dari server resmi MikroTik...${NC}"
wget -O "$CHR_ZIP" "$CHR_URL"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}[ERROR] Gagal download!${NC}"
    exit 1
fi

echo -e "${YELLOW}[INFO] Mengekstrak file...${NC}"
unzip -o "$CHR_ZIP"

echo -e "${YELLOW}[INFO] Menulis image ke ${DISK_PATH}...${NC}"
dd if="$CHR_FILE" of="$DISK_PATH" bs=4M oflag=sync status=progress

rm -f "$CHR_ZIP" "$CHR_FILE"

echo ""
echo -e "${GREEN}=============================================="
echo " INSTALASI SELESAI!"
echo " Login: user=admin | password=kosong"
echo " Group: full (default resmi MikroTik)"
echo -e "==============================================${NC}"
sleep 5
reboot
