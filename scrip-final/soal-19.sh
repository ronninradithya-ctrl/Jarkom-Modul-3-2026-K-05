#!/bin/sh
set -eu
# Soal 19 - K05 (10.66). Salin ke /root/soal_19.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.
# Jalankan cache dan rate sebagai pengujian terpisah.

case "$(hostname)" in
  gojo)
    # Cache frontend 10 menit dan limit API 10r/s

case "${1:-status}" in
  setup)
    mkdir -p /var/cache/nginx/soal19 /var/log/nginx
    cat > /etc/nginx/sites-available/soal14-proxy.conf <<'NGINX'
proxy_cache_path /var/cache/nginx/soal19 levels=1:2 keys_zone=frontend_cache:10m inactive=60m;
limit_req_zone $binary_remote_addr zone=api_per_ip:10m rate=10r/s;

log_format soal20 'client=$remote_addr run=$http_x_benchmark_run "$request" status=$status limit=$limit_req_status upstream=$upstream_status addr=$upstream_addr rt=$request_time';

upstream frontend_cluster {
    server 10.66.4.3:80;
    server 10.66.4.4:80;
}

server {
    listen 80 default_server;
    server_name jujutsu.k05.com www.jujutsu.k05.com;

    access_log /var/log/nginx/access.log;
    access_log /var/log/nginx/soal20-access.log soal20;

    location = /api {
        limit_req zone=api_per_ip;
        limit_req_status 503;

        proxy_pass http://10.66.4.2;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

    location ^~ /api/ {
        limit_req zone=api_per_ip;
        limit_req_status 503;
        proxy_pass http://10.66.4.2;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

    location / {
        proxy_cache frontend_cache;
        proxy_cache_key "$scheme$host$request_uri";
        proxy_cache_valid 200 10m;
        add_header X-Cache-Status $upstream_cache_status always;

        proxy_pass http://frontend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
NGINX
    nginx -t
    service nginx reload
    ;;
  status)
    nginx -t
    grep -E 'proxy_cache_path|proxy_cache_valid|X-Cache-Status|limit_req_zone|limit_req zone' /etc/nginx/sites-available/soal14-proxy.conf
    ;;
  *) echo 'Pakai: setup|status' >&2; exit 2 ;;
esac
    ;;
  itadori)
    # Uji cache atau rate limit secara terpisah

case "${1:-}" in
  cache)
    u="http://jujutsu.k05.com/?uji19=$(date +%s)"
    curl -sS -D - -o /dev/null "$u" | grep -Ei 'HTTP/|X-Cache-Status'
    curl -sS -D - -o /dev/null "$u" | grep -Ei 'HTTP/|X-Cache-Status'
    ;;
  rate)
    i=1
    while [ "$i" -le 30 ]; do
      curl -s -o /dev/null -w 'HTTP %{http_code}\n' http://jujutsu.k05.com/api &
      i=$((i + 1))
    done
    wait
    ;;
  *) echo 'Pakai: cache|rate' >&2; exit 2 ;;
esac
    ;;
  *)
    echo "Soal 19: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
