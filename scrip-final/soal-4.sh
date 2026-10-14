#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 4
# Satu file per soal, tiap node memakai fungsi terpisah.
# Sumber: file .sh yang diunggah; bukan script baru yang direka ulang.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: TENGEN — sumber soal-4-tengen.sh
# ================================================================
run_tengen() {
# REKONSTRUKSI DOKUMENTASI: Soal 4 (bukan file asli dari Tengen).
# Jangan eksekusi sebagai instalasi: konfigurasi asli Soal 4 sudah ada di Tengen.
# Bukti: Itadori .2.10, Fushiguro .2.11, Zenin .2.70, Okkotsu .2.71.
set -e
echo '===== KELAS DAN POOL JARINGAN 2 ====='
grep -nE 'class "NET2_|subclass "NET2_|range 10\.66\.2\.|allow members|deny members' /etc/dhcp/dhcpd.conf
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
