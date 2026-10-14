#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 9
# Satu file per soal, tiap node memakai fungsi terpisah.
# Sumber: file .sh yang diunggah; bukan script baru yang direka ulang.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: JICHI — sumber soal-9-jichi.sh
# ================================================================
run_jichi() {
set -e
ACTION="${1:-}"
case "$ACTION" in
 stop)
  echo 'SOAL 9 - DHCP RELAY DOWN'
  service isc-dhcp-relay stop || true
  pkill -x dhcrelay 2>/dev/null || true
  sleep 1
  if pgrep -x dhcrelay >/dev/null; then echo 'ERROR: DHCP Relay masih berjalan'; exit 1; fi
  echo 'OK: DHCP Relay sudah berhenti' ;;
 start)
  echo 'SOAL 9 - DHCP RELAY RECOVERY'
  service isc-dhcp-relay restart
  pgrep -a dhcrelay || { echo 'ERROR: Relay tidak aktif'; exit 1; }
  echo 'OK: DHCP Relay aktif' ;;
 status)
  if pgrep -x dhcrelay >/dev/null; then echo 'STATUS: RUNNING'; pgrep -a dhcrelay; else echo 'STATUS: STOPPED'; fi ;;
 *) echo "Gunakan: $0 stop|start|status"; exit 1 ;;
esac
}

# ================================================================
# BAGIAN NODE: ITADORI — sumber soal-9-itadori.sh
# ================================================================
run_itadori() {
ACTION=${1:-}
case "$ACTION" in fail|recover) ;; *) echo "Gunakan: $0 fail|recover"; exit 1;; esac
echo "SOAL 9 - DHCP TEST: $ACTION"
killall udhcpc 2>/dev/null || true
ip link set eth0 up
ip -4 addr flush dev eth0
ip route del default 2>/dev/null || true
udhcpc -i eth0 -q -n -t 3 -T 3
RESULT=$?
hostname; ip -br addr show eth0; ip route
if [ "$ACTION" = fail ]; then
  if [ "$RESULT" -ne 0 ]; then echo 'OK: DHCP GAGAL SAAT RELAY MATI'; else echo 'WARNING: DHCP tetap berhasil'; exit 1; fi
else
  if [ "$RESULT" -eq 0 ]; then echo 'OK: DHCP BERHASIL SETELAH RELAY DIPULIHKAN'; else echo 'ERROR: DHCP belum pulih'; exit 1; fi
fi
}

# ================================================================
# PEMILIHAN NODE
# ================================================================
case "$NODE" in
  jichi) run_jichi "$@" ;;
  itadori) run_itadori "$@" ;;
  *)
    echo "ERROR: Soal ini tidak punya script untuk node: $NODE" >&2
    echo "Node tersedia: jichi, itadori" >&2
    exit 1
    ;;
esac
