#!/bin/sh
set -eu
# Soal 16 - K05 (10.66). Salin ke /root/soal_16.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.
# Konfigurasi dipasang dengan Soal 14; file ini adalah uji Soal 16.

case "$(hostname)" in
  gojo)
    # Periksa path-based routing yang dipasang pada Soal 14

nginx -t
grep -E 'frontend_cluster|server_name|location = /api|location \^~ /api/|proxy_pass' /etc/nginx/sites-available/soal14-proxy.conf
service nginx status
    ;;
  itadori)
    # Uji domain utama, www, dan API dari Divisi A

case "${1:-all}" in
  frontend|all)
    i=1
    while [ "$i" -le 4 ]; do
      # Query unik diperlukan bila cache dari Soal 19 sudah aktif.
      curl -sS "http://jujutsu.k05.com/?soal16=$i"
      i=$((i + 1))
    done
    curl -sS 'http://www.jujutsu.k05.com/?soal16=www'
    ;;
esac
case "${1:-all}" in
  api|all)
    i=1
    while [ "$i" -le 8 ]; do
      curl -sS http://jujutsu.k05.com/api
      printf '\n'
      i=$((i + 1))
    done
    ;;
esac
    ;;
  *)
    echo "Soal 16: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
