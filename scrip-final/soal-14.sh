#!/bin/sh
set -eu
# Soal 14 - K05 (10.66). Salin ke /root/soal_14.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.
# Jalankan setup hanya pada tahap Soal 14; setup menulis konfigurasi awal.
# Sesudah Stop/Start, pemulihan worker/Geto memakai recovery/gns3-service-boot.sh;
# Gojo memakai recovery/gojo-nginx-boot.sh. Jangan ulang setup awal.

case "$(hostname)" in
  maki|panda)
    # Frontend Nginx + PHP-FPM; setup nama-node atau start
case "${1:-}" in
  setup)
    NODE="${2:-}"
    case "$NODE" in maki|panda) ;; *) echo 'Pakai: setup maki|panda'; exit 1 ;; esac
    [ "$(hostname)" = "$NODE" ] || {
      echo "Hostname node bukan $NODE"; exit 1;
    }

    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx php-fpm php-mysql curl
    FPM="$(find /etc/init.d -maxdepth 1 -name 'php*-fpm' -printf '%f\n' | sort -V | tail -n 1)"
    [ -n "$FPM" ] || { echo 'PHP-FPM tidak ditemukan'; exit 1; }
    service "$FPM" start

    mkdir -p /var/www/soal14
    cat > /var/www/soal14/index.php <<'PHP'
<?php
header('Content-Type: text/plain; charset=UTF-8');
echo "frontend=" . gethostname() . "\n";
PHP

    cat > /etc/nginx/sites-available/soal14-frontend.conf <<'NGINX'
server {
    listen 80 default_server;
    server_name _;
    return 404;
}
server {
    listen 80;
    server_name jujutsu.k05.com www.jujutsu.k05.com;
    allow 10.66.1.4;
    deny all;
    root /var/www/soal14;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:__FPM_SOCKET__;
    }
}
NGINX

    sed -i "s|__FPM_SOCKET__|/run/php/${FPM}.sock|" \
      /etc/nginx/sites-available/soal14-frontend.conf
    if [ -e /etc/nginx/sites-enabled/default ]; then
      cp -a /etc/nginx/sites-enabled/default /root/soal14-default-site.bak
      rm /etc/nginx/sites-enabled/default
    fi
    ln -sf /etc/nginx/sites-available/soal14-frontend.conf \
      /etc/nginx/sites-enabled/soal14-frontend.conf
    php -l /var/www/soal14/index.php
    nginx -t
    service nginx restart
    ;;
  start)
    FPM="$(find /etc/init.d -maxdepth 1 -name 'php*-fpm' -printf '%f\n' | sort -V | tail -n 1)"
    service "$FPM" start
    service nginx start
    ;;
  *)
    echo 'Pakai: sh /root/soal14-frontend.sh setup maki|panda'
    echo 'atau: sh /root/soal14-frontend.sh start'
    exit 1
    ;;
esac
    ;;
  nanami|todo|kirara)
    # Worker API Nginx + PHP-FPM; setup nama-node atau start
case "${1:-}" in
  setup)
    NODE="${2:-}"
    case "$NODE" in nanami|todo|kirara) ;; *) echo 'Pakai: setup nanami|todo|kirara'; exit 1 ;; esac
    [ "$(hostname)" = "$NODE" ] || {
      echo "Hostname node bukan $NODE"; exit 1;
    }

    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx php-fpm php-mysql curl
    FPM="$(find /etc/init.d -maxdepth 1 -name 'php*-fpm' -printf '%f\n' | sort -V | tail -n 1)"
    [ -n "$FPM" ] || { echo 'PHP-FPM tidak ditemukan'; exit 1; }
    service "$FPM" start

    mkdir -p /var/www/soal14
    cat > /var/www/soal14/api.php <<'PHP'
<?php
header('Content-Type: application/json; charset=UTF-8');
$worker = gethostname();
$proxyIp = $_SERVER['REMOTE_ADDR'] ?? '';
$clientIp = $proxyIp;
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';

try {
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    $db = new mysqli(
        '10.66.4.8', 'shibuya_app', 'K05_App_2026_13', 'db_shibuya_k05'
    );
    $stmt = $db->prepare(
        'INSERT INTO request_logs
         (worker_name, client_ip, proxy_ip, user_agent)
         VALUES (?, ?, ?, ?)'
    );
    $stmt->bind_param('ssss', $worker, $clientIp, $proxyIp, $userAgent);
    $stmt->execute();
    echo json_encode([
        'status' => 'ok',
        'worker' => $worker,
        'log_id' => $db->insert_id
    ]);
    $db->close();
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['status' => 'database_error', 'worker' => $worker]);
}
PHP

    cat > /etc/nginx/sites-available/soal14-api.conf <<'NGINX'
server {
    listen 80 default_server;
    server_name _;
    return 404;
}
server {
    listen 80;
    server_name jujutsu.k05.com www.jujutsu.k05.com;
    allow 10.66.4.2;
    deny all;
    root /var/www/soal14;

    location = /api {
        rewrite ^ /api.php last;
    }
    location = /api.php {
        internal;
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:__FPM_SOCKET__;
    }
    location / {
        return 404;
    }
}
NGINX

    sed -i "s|__FPM_SOCKET__|/run/php/${FPM}.sock|" \
      /etc/nginx/sites-available/soal14-api.conf
    if [ -e /etc/nginx/sites-enabled/default ]; then
      cp -a /etc/nginx/sites-enabled/default /root/soal14-default-site.bak
      rm /etc/nginx/sites-enabled/default
    fi
    ln -sf /etc/nginx/sites-available/soal14-api.conf \
      /etc/nginx/sites-enabled/soal14-api.conf
    php -l /var/www/soal14/api.php
    nginx -t
    service nginx restart
    ;;
  start)
    FPM="$(find /etc/init.d -maxdepth 1 -name 'php*-fpm' -printf '%f\n' | sort -V | tail -n 1)"
    service "$FPM" start
    service nginx start
    ;;
  *)
    echo 'Pakai: sh /root/soal14-api.sh setup nanami|todo|kirara'
    echo 'atau: sh /root/soal14-api.sh start'
    exit 1
    ;;
esac
    ;;
  geto|gojo)
    # Proxy awal; setup nama-node atau start
case "${1:-}" in
  setup)
    NODE="${2:-}"
    case "$NODE" in geto|gojo) ;; *) echo 'Pakai: setup geto|gojo'; exit 1 ;; esac
    [ "$(hostname)" = "$NODE" ] || {
      echo "Hostname node bukan $NODE"; exit 1;
    }

    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl

    if [ "$NODE" = geto ]; then
      cat > /etc/nginx/sites-available/soal14-proxy.conf <<'NGINX'
upstream api_cluster {
    server 10.66.4.5:80;
    server 10.66.4.6:80;
}
server {
    listen 80 default_server;
    server_name _;
    location = /api {
        proxy_pass http://api_cluster;
        proxy_set_header Host jujutsu.k05.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    location / { return 404; }
}
NGINX
    else
      cat > /etc/nginx/sites-available/soal14-proxy.conf <<'NGINX'
upstream frontend_cluster {
    server 10.66.4.3:80;
    server 10.66.4.4:80;
}
server {
    listen 80 default_server;
    server_name jujutsu.k05.com www.jujutsu.k05.com;
    location = /api {
        proxy_pass http://10.66.4.2;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    location / {
        proxy_pass http://frontend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX
    fi

    if [ -e /etc/nginx/sites-enabled/default ]; then
      cp -a /etc/nginx/sites-enabled/default /root/soal14-default-site.bak
      rm /etc/nginx/sites-enabled/default
    fi
    ln -sf /etc/nginx/sites-available/soal14-proxy.conf \
      /etc/nginx/sites-enabled/soal14-proxy.conf
    nginx -t
    service nginx restart
    ;;
  start)
    service nginx start
    ;;
  *)
    echo 'Pakai: sh /root/soal14-proxy.sh setup geto|gojo'
    echo 'atau: sh /root/soal14-proxy.sh start'
    exit 1
    ;;
esac
    ;;
  *)
    echo "Soal 14: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
