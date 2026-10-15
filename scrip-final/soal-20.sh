#!/bin/sh
set -eu
# Soal 20 - K05 (10.66). Salin ke /root/soal_20.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.
# Urutan: web, baseline-off, baseline, rate-on, active, audit.
# Mode baseline-off hanya untuk uji; akhiri dengan rate-on.
# Config final Gojo dipulihkan saat boot oleh recovery/gojo-nginx-boot.sh.

case "$(hostname)" in
  kusakabe)
    # Apache Benchmark dari klien Network 3

if ! command -v ab >/dev/null 2>&1; then
  apk add --no-cache apache2-utils
fi
case "${1:-}" in
  web)
    ab -q -n 600 -c 30 -l -H 'X-Benchmark-Run: web' \
      http://jujutsu.k05.com/ | tee /root/soal20-web.txt
    ;;
  baseline)
    ab -q -n 600 -c 30 -l -H 'X-Benchmark-Run: api_baseline' \
      http://jujutsu.k05.com/api | tee /root/soal20-api-baseline.txt
    ;;
  active)
    ab -q -n 600 -c 30 -l -H 'X-Benchmark-Run: api_active' \
      http://jujutsu.k05.com/api | tee /root/soal20-api-active.txt
    ;;
  *) echo 'Pakai: web|baseline|active' >&2; exit 2 ;;
esac
    ;;
  gojo)
    # Baseline sementara dan audit access log

CONF=/etc/nginx/sites-available/soal14-proxy.conf
case "${1:-}" in
  baseline-off)
    cp -p "$CONF" /root/soal20-before-baseline.conf
    sed -i '/^[[:space:]]*limit_req zone=api_per_ip;/d' "$CONF"
    nginx -t && service nginx reload
    ;;
  rate-on)
    cp -p /root/soal20-before-baseline.conf "$CONF"
    nginx -t && service nginx reload
    ;;
  audit)
    for run in api_baseline api_active; do
      echo "=== $run ==="
      grep "run=$run " /var/log/nginx/soal20-access.log |
        grep -oE 'status=[0-9]+' | sort | uniq -c
    done
    grep 'run=api_active ' /var/log/nginx/soal20-access.log |
      grep 'limit=REJECTED' | head -n 5 || true
    ;;
  *) echo 'Pakai: baseline-off|rate-on|audit' >&2; exit 2 ;;
esac
    ;;
  *)
    echo "Soal 20: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
