#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 6
# Satu file per soal, tiap node memakai fungsi terpisah.
# Sumber: file .sh yang diunggah; bukan script baru yang direka ulang.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: TENGEN — sumber soal-6-tengen.sh
# ================================================================
run_tengen() {
# REKONSTRUKSI: reservation Kugisaki, idempotent untuk file yang sudah terpasang.
set -e
if ! grep -Eq '^[[:space:]]*host[[:space:]]+kugisaki[[:space:]]*\{' /etc/dhcp/dhcpd.conf; then
 cp -a /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.pre-soal6
 cat >> /etc/dhcp/dhcpd.conf <<'CFG'
host kugisaki {
  hardware ethernet 02:42:c0:e6:67:00;
  fixed-address 10.66.3.99;
}
CFG
fi
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
grep -A4 -B1 'host kugisaki' /etc/dhcp/dhcpd.conf
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
