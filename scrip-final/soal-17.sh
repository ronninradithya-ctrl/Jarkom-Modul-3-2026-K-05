#!/bin/sh
set -eu
# Soal 17 - K05 (10.66). Salin ke /root/soal_17.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.

case "$(hostname)" in
  gojo)
    # Header X-Real-IP dan X-Forwarded-For
#!/bin/sh

set -eu



CONF=/etc/nginx/sites-available/soal14-proxy.conf

BACKUP=/root/soal17-gojo-before.conf



case "${1:-status}" in

  setup)

    [ "$(hostname)" = gojo ] || { echo 'Jalankan di Gojo'; exit 1; }

    cp -p "$CONF" "$BACKUP"

    sed -i 's/proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;/proxy_set_header X-Forwarded-For $remote_addr;/' "$CONF"

    grep -Fq 'proxy_set_header X-Real-IP $remote_addr;' "$CONF"

    grep -Fq 'proxy_set_header X-Forwarded-For $remote_addr;' "$CONF"

    if ! nginx -t; then cp -p "$BACKUP" "$CONF"; exit 1; fi

    nginx -s reload

    ;;

  status)

    nginx -t

    grep -E 'X-Real-IP|X-Forwarded-For' "$CONF"

    ;;

  *) echo 'Pakai: sh /root/soal17-gojo.sh setup|status'; exit 1 ;;

esac
    ;;
  geto)
    # Hanya percaya IP asli dari Gojo
#!/bin/sh

set -eu



CONF=/etc/nginx/sites-available/soal14-proxy.conf

BACKUP=/root/soal17-geto-before.conf



case "${1:-status}" in

  setup)

    [ "$(hostname)" = geto ] || { echo 'Jalankan di Geto'; exit 1; }

    cp -p "$CONF" "$BACKUP"

    if ! grep -Fq 'set_real_ip_from 10.66.1.4;' "$CONF"; then

      sed -i '/server_name _;/a\    set_real_ip_from 10.66.1.4;\n    real_ip_header X-Real-IP;' "$CONF"

    fi

    sed -i 's/proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;/proxy_set_header X-Forwarded-For $remote_addr;/' "$CONF"

    grep -Fq 'server 10.66.4.5:80 weight=3;' "$CONF"

    grep -Fq 'server 10.66.4.6:80 weight=1;' "$CONF"

    grep -Fq 'set_real_ip_from 10.66.1.4;' "$CONF"

    grep -Fq 'proxy_set_header X-Forwarded-For $remote_addr;' "$CONF"

    if ! nginx -t; then cp -p "$BACKUP" "$CONF"; exit 1; fi

    nginx -s reload

    ;;

  status)

    nginx -t

    grep -E 'weight=|set_real_ip_from|real_ip_header|X-Real-IP|X-Forwarded-For' "$CONF"

    ;;

  *) echo 'Pakai: sh /root/soal17-geto.sh setup|status'; exit 1 ;;

esac
    ;;
  nanami|todo|kirara)
    # Validasi IP klien sebelum INSERT ke Yaga
FILE=/var/www/soal14/api.php
BACKUP=/root/soal17-api-before.php

case "${1:-status}" in
  setup)
    case "$(hostname)" in nanami|todo|kirara) ;; *) echo 'Jalankan di Nanami, Todo, atau Kirara'; exit 1 ;; esac
    cp -p "$FILE" "$BACKUP"
    if grep -Fq '$clientIp = $proxyIp;' "$FILE"; then
      sed -i '/^\$clientIp = \$proxyIp;$/c\
$clientIp = trim($_SERVER["HTTP_X_REAL_IP"] ?? "");\
$forwardedIp = trim($_SERVER["HTTP_X_FORWARDED_FOR"] ?? "");\
if ($proxyIp !== "10.66.4.2" || !filter_var($clientIp, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4) || $forwardedIp !== $clientIp) {\
    http_response_code(400);\
    echo json_encode(["status" => "invalid_client_ip"]);\
    exit;\
}' "$FILE"
    fi
    if ! php -l "$FILE"; then cp -p "$BACKUP" "$FILE"; exit 1; fi
    service php8.4-fpm reload
    ;;
  status)
    php -l "$FILE"
    grep -nE 'proxyIp|clientIp|forwardedIp|FILTER_VALIDATE_IP' "$FILE" | head -12
    ;;
  *) echo 'Pakai: sh /root/soal17-api.sh setup|status'; exit 1 ;;
esac
    ;;
  *)
    echo "Soal 17: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
