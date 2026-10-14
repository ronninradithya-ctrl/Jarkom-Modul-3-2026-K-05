#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 1
# Satu file per soal, tiap node memakai fungsi terpisah.
# Sumber: file .sh yang diunggah; bukan script baru yang direka ulang.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: JICHI — sumber soal-1-jichi.sh
# ================================================================
run_jichi() {
# REKONSTRUKSI berdasarkan bukti konfigurasi Jichi, bukan salinan script asli.
set -e
ip link set eth0 up
ip -4 addr flush dev eth0
udhcpc -i eth0 -q -n || true
for spec in 'eth1 1' 'eth2 2' 'eth3 3' 'eth4 4'; do
  set -- $spec
  ip link set "$1" up
  ip -4 addr replace "10.66.$2.1/24" dev "$1"
done
ip route replace default via 192.168.122.1 dev eth0
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -C POSTROUTING -s 10.66.0.0/16 -o eth0 -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -s 10.66.0.0/16 -o eth0 -j MASQUERADE
ip -br addr; ip route
iptables -t nat -L POSTROUTING -n -v
}

# ================================================================
# BAGIAN NODE: UTAHIME — sumber soal-1-utahime.sh
# ================================================================
run_utahime() {
# REKONSTRUKSI dari bukti konfigurasi utahime.
set -e
ip link set eth0 up
ip -4 addr flush dev eth0
ip addr add 10.66.1.2/24 dev eth0
ip route replace default via 10.66.1.1 dev eth0
ip -br addr; ip route
}

# ================================================================
# BAGIAN NODE: SHOKO — sumber soal-1-shoko.sh
# ================================================================
run_shoko() {
# REKONSTRUKSI dari bukti konfigurasi shoko.
set -e
ip link set eth0 up
ip -4 addr flush dev eth0
ip addr add 10.66.1.3/24 dev eth0
ip route replace default via 10.66.1.1 dev eth0
ip -br addr; ip route
}

# ================================================================
# BAGIAN NODE: TENGEN — sumber soal-1-tengen.sh
# ================================================================
run_tengen() {
# REKONSTRUKSI dari bukti konfigurasi tengen.
set -e
ip link set eth0 up
ip -4 addr flush dev eth0
ip addr add 10.66.4.10/24 dev eth0
ip route replace default via 10.66.4.1 dev eth0
ip -br addr; ip route
}

# ================================================================
# PEMILIHAN NODE
# ================================================================
case "$NODE" in
  jichi) run_jichi "$@" ;;
  utahime) run_utahime "$@" ;;
  shoko) run_shoko "$@" ;;
  tengen) run_tengen "$@" ;;
  *)
    echo "ERROR: Soal ini tidak punya script untuk node: $NODE" >&2
    echo "Node tersedia: jichi, utahime, shoko, tengen" >&2
    exit 1
    ;;
esac
