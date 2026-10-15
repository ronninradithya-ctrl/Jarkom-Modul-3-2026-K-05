#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 7
# Satu file per soal, tiap node memakai fungsi terpisah.
# Audit alamat saat layanan hidup. Pemulihan DHCP client setelah boot
# memakai recovery/alpinet-client-boot.sh di /root/soal7-client-dhcp.sh.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: CLIENT — sumber soal-7-client.sh
# ================================================================
run_client() {
# REKONSTRUKSI audit client (outputnya telah dibuktikan melalui screenshot).
set -u
HOST=$(hostname)
IP=$(ip -4 -o addr show eth0 | awk '{print $4}' | head -1)
GW=$(ip -4 route show default | awk '/default/{print $3;exit}')
echo '===== SOAL 7 - AUDIT CLIENT ====='
echo "HOSTNAME: $HOST"
echo "IP      : $IP"
echo "GATEWAY : $GW"
ip -br addr show eth0
ip route
cat /etc/resolv.conf
case "$HOST" in
 itadori|fushiguro) EXPECT=10.66.2.1; TYPE='NET2 POOL1' ;;
 zenin|okkotsu) EXPECT=10.66.2.1; TYPE='NET2 POOL2' ;;
 ino|kusakabe|miwa|mlwa|kugisaki) EXPECT=10.66.3.1; TYPE='NET3' ;;
 *) echo 'Hostname tidak dikenali'; exit 1 ;;
esac
echo "POOL: $TYPE"
[ "$GW" = "$EXPECT" ] || { echo 'GATEWAY TIDAK SESUAI'; exit 1; }
case "$HOST:$IP" in
 kugisaki:10.66.3.99/24|itadori:10.66.2.*/24|fushiguro:10.66.2.*/24|zenin:10.66.2.*/24|okkotsu:10.66.2.*/24|ino:10.66.3.*/24|kusakabe:10.66.3.*/24|miwa:10.66.3.*/24|mlwa:10.66.3.*/24) ;;
 *) echo 'IP tidak sesuai subnet'; exit 1 ;;
esac
ping -c 2 "$GW" || exit 1
ping -c 2 10.66.4.10 || exit 1
echo 'HASIL: CLIENT TERHUBUNG - periksa pool dan DNS manual'
}

# ================================================================
# PEMILIHAN NODE
# ================================================================
case "$NODE" in
  itadori|fushiguro|zenin|okkotsu|ino|kusakabe|miwa|mlwa|kugisaki) run_client "$@" ;;
  *)
    echo "ERROR: Soal ini tidak punya script untuk node: $NODE" >&2
    echo "Node tersedia: client" >&2
    exit 1
    ;;
esac
