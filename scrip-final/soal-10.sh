#!/bin/bash
# PRAKTIKUM MODUL 3 K-05 — SOAL 10
# Satu file per soal, tiap node memakai fungsi terpisah.
# Sumber: file .sh yang diunggah; bukan script baru yang direka ulang.
# Jalankan sebagai root pada node yang sesuai.
set -e

NODE="$(hostname | tr "[:upper:]" "[:lower:]")"

# ================================================================
# BAGIAN NODE: JICHI — sumber soal-10-jichi.sh
# ================================================================
run_jichi() {
set -e
cat > /root/soal10-jichi-startup.sh <<'STARTUP'
#!/bin/sh
LOG=/root/soal10-jichi-startup.log
echo '===== STARTUP DHCP RELAY =====' >> "$LOG"
date >> "$LOG"
i=0
while ! ip -4 addr show dev eth4 | grep -q '10.66.4.1/24'; do
  i=$((i+1)); [ "$i" -lt 15 ] || { echo 'ERROR: eth4 belum siap' >> "$LOG"; exit 1; }
  sleep 1
done
sysctl -w net.ipv4.ip_forward=1 >> "$LOG" 2>&1
if ! pgrep -x dhcrelay >/dev/null; then service isc-dhcp-relay start >> "$LOG" 2>&1; fi
if pgrep -x dhcrelay >/dev/null; then echo 'OK: DHCP Relay RUNNING' >> "$LOG"; pgrep -a dhcrelay >> "$LOG"; else exit 1; fi
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
cat > /root/soal10-tengen-startup.sh <<'STARTUP'
#!/bin/sh
LOG=/root/soal10-tengen-startup.log
echo '===== STARTUP DHCP SERVER =====' >> "$LOG"
date >> "$LOG"
i=0
while ! ip -4 addr show dev eth0 | grep -q '10.66.4.10/24'; do
  i=$((i+1)); [ "$i" -lt 15 ] || { echo 'ERROR: eth0 belum siap' >> "$LOG"; exit 1; }
  sleep 1
done
dhcpd -t -cf /etc/dhcp/dhcpd.conf >> "$LOG" 2>&1 || exit 1
if ! pgrep -x dhcpd >/dev/null; then rm -f /var/run/dhcpd.pid; service isc-dhcp-server start >> "$LOG" 2>&1; fi
if pgrep -x dhcpd >/dev/null; then echo 'OK: DHCP Server RUNNING' >> "$LOG"; pgrep -a dhcpd >> "$LOG"; else exit 1; fi
STARTUP
chmod +x /root/soal10-tengen-startup.sh
if [ -f /root/init.sh ]; then cp -p /root/init.sh /root/init.sh.backup-soal10; else printf '#!/bin/sh\n' > /root/init.sh; fi
if ! grep -Fq /root/soal10-tengen-startup.sh /root/init.sh; then printf '\n# SOAL 10 - Autostart DHCP Server\n/root/soal10-tengen-startup.sh >> /root/soal10-tengen-startup.log 2>&1\n' >> /root/init.sh; fi
chmod +x /root/init.sh
sh -n /root/init.sh && sh -n /root/soal10-tengen-startup.sh
dhcpd -t -cf /etc/dhcp/dhcpd.conf
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
# REFERENSI FILE STARTUP DAN INIT.SH
# Script utama di atas SUDAH membuat helper startup otomatis,
# serta menambah hook ke /root/init.sh. Teks di bawah adalah
# lampiran referensi, tidak dieksekusi ulang.
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
if ! pgrep -x dhcrelay >/dev/null; then service isc-dhcp-relay start >> "$LOG" 2>&1; fi
pgrep -a dhcrelay >> "$LOG" || exit 1
echo 'OK: DHCP Relay RUNNING' >> "$LOG"

=== soal-10-tengen-startup.sh ===
#!/bin/sh
# Dihasilkan oleh soal-10-tengen.sh; pertahankan bersama init.sh.
LOG=/root/soal10-tengen-startup.log
printf '===== STARTUP DHCP SERVER =====\n' >> "$LOG"
date >> "$LOG"
i=0
while ! ip -4 addr show dev eth0 | grep -q '10.66.4.10/24'; do
 i=$((i+1)); [ "$i" -lt 15 ] || exit 1; sleep 1
done
dhcpd -t -cf /etc/dhcp/dhcpd.conf >> "$LOG" 2>&1 || exit 1
if ! pgrep -x dhcpd >/dev/null; then rm -f /var/run/dhcpd.pid; service isc-dhcp-server start >> "$LOG" 2>&1; fi
pgrep -a dhcpd >> "$LOG" || exit 1
echo 'OK: DHCP Server RUNNING' >> "$LOG"

=== init-jichi.sh ===
#!/bin/sh
# Isi /root/init.sh untuk node Jichi
/root/soal10-jichi-startup.sh >> /root/soal10-jichi-startup.log 2>&1

=== init-tengen.sh ===
#!/bin/sh
# Isi /root/init.sh untuk node Tengen
/root/soal10-tengen-startup.sh >> /root/soal10-tengen-startup.log 2>&1

REFERENSI_SOAL_10
