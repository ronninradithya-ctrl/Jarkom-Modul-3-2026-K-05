#!/bin/sh
set -eu
# Soal 15 - K05 (10.66). Salin ke /root/soal_15.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.

case "$(hostname)" in
  geto)
    # Set bobot Nanami:Todo 3:1 atau periksa status
CONF=/etc/nginx/sites-available/soal14-proxy.conf

case "${1:-}" in
  setup)
    [ "$(hostname)" = geto ] || {
      echo 'Jalankan hanya di Geto'; exit 1;
    }
    [ -f "$CONF" ] || {
      echo "File konfigurasi nomor 14 tidak ada: $CONF"; exit 1;
    }
    grep -Fq 'upstream api_cluster {' "$CONF" || {
      echo 'upstream api_cluster tidak ditemukan'; exit 1;
    }

    cp "$CONF" /root/soal15-geto-sebelum.conf

    sed -i -E \
      's/server 10\.66\.4\.5:80([[:space:]]+weight=[0-9]+)?;/server 10.66.4.5:80 weight=3;/; s/server 10\.66\.4\.6:80([[:space:]]+weight=[0-9]+)?;/server 10.66.4.6:80 weight=1;/' \
      "$CONF"

    grep -Fq 'server 10.66.4.5:80 weight=3;' "$CONF" || {
      echo 'Baris Nanami tidak ditemukan'; exit 1;
    }
    grep -Fq 'server 10.66.4.6:80 weight=1;' "$CONF" || {
      echo 'Baris Todo tidak ditemukan'; exit 1;
    }

    if ! nginx -t; then
      cp /root/soal15-geto-sebelum.conf "$CONF"
      echo 'Sintaks gagal; konfigurasi lama dikembalikan'
      exit 1
    fi

    nginx -s reload
    echo '=== UPSTREAM API ==='
    grep -A 4 '^upstream api_cluster' "$CONF"
    ;;

  status)
    nginx -t
    grep -A 4 '^upstream api_cluster' "$CONF"
    ;;

  *)
    echo 'Pakai: sh /root/soal15-geto.sh setup|status'
    exit 1
    ;;
esac
    ;;
  maki)
    # 40 request langsung ke Geto dari Data Center
RESULT=/root/soal15-hasil-40.txt
: > "$RESULT"

i=1
while [ "$i" -le 40 ]; do
    body="$(curl -fsS -H 'Host: jujutsu.k05.com' \
      http://10.66.4.2/api)"

    printf '%s\n' "$body" | grep -Fq '"status":"ok"' || {
      echo "Request $i gagal: $body" >&2
      exit 1
    }

    worker="$(printf '%s\n' "$body" |
      sed -n 's/.*"worker":"\([^"]*\)".*/\1/p')"

    case "$worker" in
      nanami|todo) ;;
      *) echo "Worker tidak dikenal pada request $i: $body" >&2; exit 1 ;;
    esac

    printf '%s\n' "$worker" >> "$RESULT"
    i=$((i + 1))
done

echo '=== JUMLAH RESPON PER WORKER ==='
sort "$RESULT" | uniq -c
echo '=== RINGKASAN ==='
awk '{ n[$1]++ }
     END {
       printf "Nanami=%d Todo=%d Total=%d\n",
              n["nanami"], n["todo"], NR
     }' "$RESULT"
    ;;
  *)
    echo "Soal 15: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
