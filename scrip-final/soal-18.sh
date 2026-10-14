#!/bin/sh
set -eu
# Soal 18 - K05 (10.66). Salin ke /root/soal_18.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.
# Setelah uji, jalankan start pada Nanami dan Todo.

case "$(hostname)" in
  geto)
    # Backup Kirara dan passive health check

case "${1:-status}" in
  setup)
    cat > /etc/nginx/sites-available/soal14-proxy.conf <<'NGINX'
upstream api_cluster {
    server 10.66.4.5:80 weight=3 max_fails=2 fail_timeout=5s;
    server 10.66.4.6:80 weight=1 max_fails=2 fail_timeout=5s;
    server 10.66.4.7:80 backup;
}
server {
    listen 80 default_server;
    server_name _;
    set_real_ip_from 10.66.1.4;
    real_ip_header X-Real-IP;
    location = /api {
        proxy_pass http://api_cluster;
        proxy_set_header Host jujutsu.k05.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
    location ^~ /api/ {
        rewrite ^/api/$ /api break;
        proxy_pass http://api_cluster;
        proxy_set_header Host jujutsu.k05.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
    location / { return 404; }
}
NGINX
    nginx -t
    service nginx reload
    ;;
  status)
    nginx -t
    grep -A 4 '^upstream api_cluster' /etc/nginx/sites-available/soal14-proxy.conf
    ;;
  *) echo 'Pakai: setup|status' >&2; exit 2 ;;
esac
    ;;
  kirara)
    # Periksa API cadangan yang dipasang pada Soal 14

service nginx status
php -l /var/www/soal14/api.php
    ;;
  nanami|todo)
    # Matikan lalu pulihkan layanan untuk simulasi

case "${1:-status}" in
  stop|start|status) service nginx "${1:-status}" ;;
  *) echo 'Pakai: stop|start|status' >&2; exit 2 ;;
esac
    ;;
  itadori)
    # Uji failover melalui Gojo; jalankan saat Nanami dan Todo mati

i=1
while [ "$i" -le 8 ]; do
  curl -sS -w ' HTTP %{http_code}\n' http://jujutsu.k05.com/api
  i=$((i + 1))
done
    ;;
  *)
    echo "Soal 18: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
