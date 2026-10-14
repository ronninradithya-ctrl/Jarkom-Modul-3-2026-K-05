#!/bin/sh
set -eu
# Soal 13 - K05 (10.66). Salin ke /root/soal_13.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.

case "$(hostname)" in
  yaga)
    # MariaDB Master; setup, schema, insert, status, start
DB='db_shibuya_k05'
REPL_PASS='K05_Repl_2026_13'
APP_PASS='K05_App_2026_13'

case "${1:-}" in
  setup)
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server mariadb-client

    cat > /etc/mysql/mariadb.conf.d/99-soal13.cnf <<'CNF'
[mysqld]
server-id=13
log_bin=/var/lib/mysql/soal13-bin
binlog_format=ROW
bind-address=10.66.4.8
skip-name-resolve
CNF

    service mariadb restart

    mariadb <<SQL
CREATE USER IF NOT EXISTS 'replica13'@'10.66.4.9' IDENTIFIED BY '${REPL_PASS}';
GRANT REPLICATION SLAVE ON *.* TO 'replica13'@'10.66.4.9';
SQL
    echo '=== STATUS MASTER: CATAT File DAN Position ==='
    mariadb -e "SELECT @@server_id AS server_id, @@log_bin AS log_bin; SHOW MASTER STATUS;"
    ;;

  schema)
    mariadb <<SQL
CREATE DATABASE IF NOT EXISTS ${DB};
CREATE TABLE IF NOT EXISTS ${DB}.request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    worker_name VARCHAR(50) NOT NULL,
    client_ip VARCHAR(50) NOT NULL,
    proxy_ip VARCHAR(50) NOT NULL,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE USER IF NOT EXISTS 'shibuya_app'@'10.66.4.0/255.255.255.0'
    IDENTIFIED BY '${APP_PASS}';
GRANT SELECT, INSERT ON ${DB}.* TO
    'shibuya_app'@'10.66.4.0/255.255.255.0';
SQL
    mariadb -e "SHOW TABLES FROM ${DB}; SHOW CREATE TABLE ${DB}.request_logs\G"
    ;;

  insert)
    mariadb -e "INSERT INTO ${DB}.request_logs
      (worker_name, client_ip, proxy_ip, user_agent)
      VALUES ('uji-yaga', '10.66.4.8', '10.66.4.8', 'uji-soal13');
      SELECT id, worker_name, client_ip, proxy_ip
      FROM ${DB}.request_logs ORDER BY id DESC LIMIT 3;"
    ;;

  status)
    service mariadb status
    mariadb -e "SELECT @@server_id AS server_id, @@log_bin AS log_bin; SHOW MASTER STATUS;"
    ;;

  start)
    service mariadb start
    ;;

  *)
    echo "Pakai: sh /root/soal13-yaga.sh {setup|schema|insert|status|start}" >&2
    exit 1
    ;;
esac
    ;;
  inumaki)
    # MariaDB Slave; setup FILE POSITION, status, start
PASS='K05_Repl_2026_13'

case "${1:-}" in
setup)
    [ "$#" -eq 3 ] || {
        echo "Pakai: sh /root/soal13-inumaki.sh setup FILE POSITION"
        exit 1
    }

    FILE="$2"
    POS="$3"

    case "$FILE" in
        ''|*[!a-zA-Z0-9._-]*)
            echo "Nama FILE tidak valid"
            exit 1
            ;;
    esac

    case "$POS" in
        ''|*[!0-9]*)
            echo "POSITION harus angka"
            exit 1
            ;;
    esac

    cat > /etc/mysql/mariadb.conf.d/99-soal13.cnf <<CNF
[mysqld]
server-id=14
relay_log=/var/lib/mysql/soal13-relay
read_only=ON
bind-address=10.66.4.9
skip-name-resolve
CNF

    service mariadb restart

    mariadb <<SQL
CHANGE MASTER TO
  MASTER_HOST='10.66.4.8',
  MASTER_PORT=3306,
  MASTER_USER='replica13',
  MASTER_PASSWORD='${PASS}',
  MASTER_LOG_FILE='${FILE}',
  MASTER_LOG_POS=${POS};
START SLAVE;
SQL

    sleep 2
    mariadb -e 'SHOW SLAVE STATUS\G' |
      grep -E 'Master_Host:|Slave_IO_Running:|Slave_SQL_Running:|Last_IO_Error:|Last_SQL_Error:'
    ;;

status)
    service mariadb status
    mariadb -e 'SHOW SLAVE STATUS\G' |
      grep -E 'Master_Host:|Slave_IO_Running:|Slave_SQL_Running:|Seconds_Behind_Master:|Last_IO_Error:|Last_SQL_Error:'
    ;;

start)
    service mariadb start
    ;;

*)
    echo "Pakai: setup FILE POSITION | status | start"
    exit 1
    ;;
esac
    ;;
  *)
    echo "Soal 13: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
