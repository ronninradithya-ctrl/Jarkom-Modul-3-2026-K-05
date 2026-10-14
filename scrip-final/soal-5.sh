#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 5
# Satu file per soal, tiap node memakai fungsi terpisah.
# Sumber: file .sh yang diunggah; bukan script baru yang direka ulang.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: TENGEN — sumber soal-5-tengen.sh
# ================================================================
run_tengen() {
# REKONSTRUKSI DOKUMENTASI: Soal 5 (tidak mengganti konfigurasi asli).
# Short Ino/Kusakabe: 10.66.3.10-89, 1800 detik.
# Long Miwa: 10.66.3.100-199, 43200 detik.
set -e
echo '===== KELAS DAN LEASE JARINGAN 3 ====='
grep -nE 'NET3_SHORT|NET3_LONG|range 10\.66\.3\.|lease-time|domain-name-servers|domain-search' /etc/dhcp/dhcpd.conf
dhcpd -t -cf /etc/dhcp/dhcpd.conf
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
