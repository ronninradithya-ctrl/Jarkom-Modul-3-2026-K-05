#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 8
# Satu file per soal, tiap node memakai fungsi terpisah.
# Sumber: file .sh yang diunggah; bukan script baru yang direka ulang.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: TENGEN — sumber soal-8-tengen.sh
# ================================================================
run_tengen() {
# REKONSTRUKSI: tangkap DORA ketika client memperbarui lease.
# Jalankan di Tengen, kemudian pada Itadori paksa request DHCP.
set -e
ACTION=${1:-show}
case "$ACTION" in
 capture) timeout 40 tcpdump -i eth0 -s 0 -nn -w /root/soal8-dhcp.pcap 'udp port 67 or udp port 68' ;;
 show)
  tcpdump -nn -vvv -r /root/soal8-dhcp.pcap 2>/dev/null | grep 'DHCP-Message (53)' || true
  tcpdump -nn -vvv -r /root/soal8-dhcp.pcap 2>/dev/null | grep -E 'Gateway-IP|Your-IP|Server-ID|Lease-Time' || true ;;
 *) echo 'Gunakan capture|show'; exit 1 ;;
esac
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
