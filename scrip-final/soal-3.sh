#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 3
# Satu file per soal, tiap node memakai fungsi terpisah.
# Sumber: file .sh yang diunggah; bukan script baru yang direka ulang.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: JICHI — sumber soal-3-jichi.sh
# ================================================================
run_jichi() {
# REKONSTRUKSI sesuai konfigurasi relay terbukti pada screenshot.
set -e
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay
cat > /etc/default/isc-dhcp-relay <<'CFG'
SERVERS="10.66.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
CFG
service isc-dhcp-relay restart
pgrep -a dhcrelay
}

# ================================================================
# PEMILIHAN NODE
# ================================================================
case "$NODE" in
  jichi) run_jichi "$@" ;;
  *)
    echo "ERROR: Soal ini tidak punya script untuk node: $NODE" >&2
    echo "Node tersedia: jichi" >&2
    exit 1
    ;;
esac
