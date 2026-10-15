#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 10
# Satu file per soal, tiap node memakai fungsi terpisah.
# Bagian Tengen diperbarui setelah uji Stop/Start menunjukkan paket DHCP
# dan /etc/dhcp/dhcpd.conf hilang dari lapisan container.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: JICHI — sumber soal-10-jichi.sh
# ================================================================
run_jichi() {
set -e
test -s /root/isc-dhcp-relay_4.4.3-P1-8_amd64.deb || {
  echo 'Paket relay di /root belum tersedia; arsipkan paket yang terpasang sebelum menguji restart' >&2
  exit 1
}
cat > /root/soal10-jichi-startup.sh <<'STARTUP'
#!/bin/sh
set -eu
LOG=/root/soal10-jichi-startup.log
DEB=/root/isc-dhcp-relay_4.4.3-P1-8_amd64.deb
echo '===== STARTUP DHCP RELAY =====' >> "$LOG"
date >> "$LOG"
i=0
until ip -4 addr show dev eth4 | grep -q '10.66.4.1/24'; do
  i=$((i+1))
  [ "$i" -lt 15 ] || { echo 'ERROR: eth4 belum siap' >> "$LOG"; exit 1; }
  sleep 1
done
sysctl -w net.ipv4.ip_forward=1 >> "$LOG" 2>&1
if ! command -v dhcrelay >/dev/null 2>&1; then
  test -s "$DEB" || { echo "ERROR: paket $DEB tidak ada" >> "$LOG"; exit 1; }
  DEBIAN_FRONTEND=noninteractive dpkg -i "$DEB" >> "$LOG" 2>&1
fi
if ! pgrep -x dhcrelay >/dev/null 2>&1; then
  /usr/sbin/dhcrelay -q -i eth2 -i eth3 -i eth4 10.66.4.10 >> "$LOG" 2>&1
fi
if pgrep -x dhcrelay >/dev/null 2>&1; then
  echo 'OK: DHCP Relay RUNNING' >> "$LOG"
  pgrep -a dhcrelay >> "$LOG"
else
  echo 'ERROR: DHCP Relay gagal aktif' >> "$LOG"
  exit 1
fi
STARTUP
chmod +x /root/soal10-jichi-startup.sh
if [ -f /root/init.sh ]; then cp -p /root/init.sh /root/init.sh.backup-soal10; else printf '#!/bin/sh\n' > /root/init.sh; fi
if ! grep -Fq /root/soal10-jichi-startup.sh /root/init.sh; then printf '\n# SOAL 10 - Autostart DHCP Relay\n/root/soal10-jichi-startup.sh >> /root/soal10-jichi-startup.log 2>&1\n' >> /root/init.sh; fi
chmod +x /root/init.sh
sh -n /root/init.sh && sh -n /root/soal10-jichi-startup.sh
/root/soal10-jichi-startup.sh
pgrep -a dhcrelay
echo 'SOAL 10 JICHI TERPASANG'
}

# ================================================================
# BAGIAN NODE: TENGEN — sumber soal-10-tengen.sh
# ================================================================
run_tengen() {
set -e
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
test -x /usr/sbin/dhcpd || { echo 'Pasang isc-dhcp-server dan jalankan setup soal 2, 4, 5, 6 dahulu' >&2; exit 1; }
/usr/sbin/dhcpd -t -cf /etc/dhcp/dhcpd.conf
mkdir -p /root/soal10-dhcp-debs
cp /etc/dhcp/dhcpd.conf /root/soal10-dhcpd.conf
# Cache paket yang akan dipakai lagi bila layer /usr dan /etc hilang saat reboot.
(cd /root/soal10-dhcp-debs && apt-get download isc-dhcp-common isc-dhcp-server)
test -n "$(find /root/soal10-dhcp-debs -name 'isc-dhcp-common_*.deb' -print -quit)"
test -n "$(find /root/soal10-dhcp-debs -name 'isc-dhcp-server_*.deb' -print -quit)"
cat > /root/soal10-tengen-startup.sh <<'STARTUP'
#!/bin/sh
set -eu
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
LOG=/root/soal10-tengen-startup.log
echo "===== RESTORE DHCP $(date) =====" >> "$LOG"
ip link set eth0 up
if ! ip -4 addr show dev eth0 | grep -q '10.66.4.10/24'; then
    ip -4 addr add 10.66.4.10/24 dev eth0
fi
ip route replace default via 10.66.4.1 dev eth0
if [ ! -x /usr/sbin/dhcpd ]; then
    dpkg -i /root/soal10-dhcp-debs/isc-dhcp-common_*.deb \
        /root/soal10-dhcp-debs/isc-dhcp-server_*.deb >> "$LOG" 2>&1
fi
test -x /usr/sbin/dhcpd
test -s /root/soal10-dhcpd.conf
mkdir -p /etc/dhcp /var/lib/dhcp
cp /root/soal10-dhcpd.conf /etc/dhcp/dhcpd.conf
printf 'INTERFACESv4="eth0"\nINTERFACESv6=""\n' > /etc/default/isc-dhcp-server
touch /var/lib/dhcp/dhcpd.leases
/usr/sbin/dhcpd -t -cf /etc/dhcp/dhcpd.conf >> "$LOG" 2>&1
service isc-dhcp-server stop >> "$LOG" 2>&1 || true
pkill -x dhcpd 2>/dev/null || true
rm -f /var/run/dhcpd.pid
service isc-dhcp-server start >> "$LOG" 2>&1
pgrep -a dhcpd | tee -a "$LOG"
STARTUP
chmod +x /root/soal10-tengen-startup.sh
if [ -f /root/init.sh ]; then cp -p /root/init.sh /root/init.sh.backup-soal10; else printf '#!/bin/sh\n' > /root/init.sh; fi
if ! grep -Fq /root/soal10-tengen-startup.sh /root/init.sh; then printf '\n# SOAL 10 - Autostart DHCP Server\n/root/soal10-tengen-startup.sh >> /root/soal10-tengen-startup.log 2>&1\n' >> /root/init.sh; fi
chmod +x /root/init.sh
sh -n /root/init.sh && sh -n /root/soal10-tengen-startup.sh
/usr/sbin/dhcpd -t -cf /etc/dhcp/dhcpd.conf
/root/soal10-tengen-startup.sh
service isc-dhcp-server status
echo 'SOAL 10 TENGEN TERPASANG'
}

# ================================================================
# PEMILIHAN NODE
# ================================================================
case "$NODE" in
  jichi) run_jichi "$@" ;;
  tengen) run_tengen "$@" ;;
  *)
    echo "ERROR: Soal ini tidak punya script untuk node: $NODE" >&2
    echo "Node tersedia: jichi, tengen" >&2
    exit 1
    ;;
esac

# ================================================================
# REFERENSI: helper aktif dibuat oleh fungsi di atas dan juga
# disimpan terpisah di recovery/tengen-dhcp-recovery.sh.
# ================================================================
: <<'REFERENSI_SOAL_10'

=== soal-10-jichi-startup.sh ===
#!/bin/sh
# Dihasilkan oleh soal-10-jichi.sh; pertahankan berkas ini bersama init.sh.
LOG=/root/soal10-jichi-startup.log
printf '===== STARTUP DHCP RELAY =====\n' >> "$LOG"
date >> "$LOG"
i=0
while ! ip -4 addr show dev eth4 | grep -q '10.66.4.1/24'; do
 i=$((i+1)); [ "$i" -lt 15 ] || exit 1; sleep 1
done
sysctl -w net.ipv4.ip_forward=1 >> "$LOG" 2>&1
if ! pgrep -x dhcrelay >/dev/null; then /usr/sbin/dhcrelay -q -i eth2 -i eth3 -i eth4 10.66.4.10 >> "$LOG" 2>&1; fi
pgrep -a dhcrelay >> "$LOG" || exit 1
echo 'OK: DHCP Relay RUNNING' >> "$LOG"

=== init-jichi.sh ===
#!/bin/sh
# Isi /root/init.sh untuk node Jichi
/root/soal10-jichi-startup.sh >> /root/soal10-jichi-startup.log 2>&1

=== init-tengen.sh ===
#!/bin/sh
# Isi /root/init.sh untuk node Tengen
/root/soal10-tengen-startup.sh >> /root/soal10-tengen-startup.log 2>&1

REFERENSI_SOAL_10
