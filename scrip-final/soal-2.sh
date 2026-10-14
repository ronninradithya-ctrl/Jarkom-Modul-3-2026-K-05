#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 2
# Satu file per soal, tiap node memakai fungsi terpisah.
# Sumber: file .sh yang diunggah; bukan script baru yang direka ulang.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: TENGEN — sumber soal-2-tengen.sh
# ================================================================
run_tengen() {
# Diadaptasi dari naskah soal2-tengen.sh yang ditemukan dalam lampiran percakapan.
# PERINGATAN: script setup awal ini MENIMPA /etc/dhcp/dhcpd.conf.
# Jangan jalankan lagi setelah konfigurasi Soal 4-6 terpasang.
set -e
PREFIX="10.66"
echo "===== SOAL 2 - DHCP SERVER TENGEN ====="
printf 'nameserver 192.168.122.1\n' > /etc/resolv.conf
ping -c 2 8.8.8.8
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server
cat > /etc/default/isc-dhcp-server <<'CFG'
INTERFACESv4="eth0"
INTERFACESv6=""
CFG
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup 2>/dev/null || true
cat > /etc/dhcp/dhcpd.conf <<'CFG'
authoritative;
ddns-update-style none;
default-lease-time 3600;
max-lease-time 7200;
subnet 10.66.4.0 netmask 255.255.255.0 {
  option subnet-mask 255.255.255.0;
  option broadcast-address 10.66.4.255;
  option routers 10.66.4.1;
}
subnet 10.66.2.0 netmask 255.255.255.0 {
  option subnet-mask 255.255.255.0;
  option broadcast-address 10.66.2.255;
  option routers 10.66.2.1;
  option domain-name-servers 10.66.1.2, 10.66.1.3;
  option domain-name "k05.com";
  option domain-search "k05.com";
}
subnet 10.66.3.0 netmask 255.255.255.0 {
  option subnet-mask 255.255.255.0;
  option broadcast-address 10.66.3.255;
  option routers 10.66.3.1;
  option domain-name-servers 10.66.1.2, 10.66.1.3;
  option domain-name "k05.com";
  option domain-search "k05.com";
}
CFG
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
}

# ================================================================
# PEMILIHAN NODE
# ================================================================
case "$NODE" in
  tengen) run_tengen "$@" ;;
  *)
    echo "ERROR: Soal ini tidak punya script untuk node: $NODE" >&2
    echo "Node tersedia: tengen" >&2
    exit 1
    ;;
esac
