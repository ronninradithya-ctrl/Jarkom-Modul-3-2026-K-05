#!/bin/sh
set -eu
# Soal 11 - K05 (10.66). Salin ke /root/soal_11.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.

case "$(hostname)" in
  utahime)
    # DNS Master; setup, bump, start, hook
ZONE="jujutsu.k05.com"
ZONE_FILE="/etc/bind/db.jujutsu.k05.com"
ZONE_CONF="/etc/bind/soal11-jujutsu.conf"

dns_service() {
    if [ -x /etc/init.d/bind9 ]; then
        service bind9 "$1"
    else
        service named "$1"
    fi
}

case "${1:-setup}" in
    setup)
        if ! command -v named >/dev/null 2>&1; then
            apt-get install -y bind9 bind9-utils
        fi

        if [ ! -f "$ZONE_FILE" ]; then
            cat > "$ZONE_FILE" <<'ZONE'
$TTL 300
@ IN SOA utahime.jujutsu.k05.com. hostmaster.jujutsu.k05.com. (
    2026101401 ; serial
    300        ; refresh
    60         ; retry
    1209600    ; expire
    300        ; negative cache TTL
)

@       IN NS utahime.jujutsu.k05.com.
@       IN NS shoko.jujutsu.k05.com.

utahime IN A 10.66.1.2
shoko   IN A 10.66.1.3
ZONE
        fi

        cat > "$ZONE_CONF" <<'CONF'
zone "jujutsu.k05.com" {
    type master;
    file "/etc/bind/db.jujutsu.k05.com";
    notify yes;
    also-notify { 10.66.1.3; };
    allow-transfer { 10.66.1.3; };
    allow-query { any; };
};
CONF

        INCLUDE='include "/etc/bind/soal11-jujutsu.conf";'

        if ! grep -Fqx "$INCLUDE" /etc/bind/named.conf.local; then
            cp -p /etc/bind/named.conf.local \
                /root/named.conf.local.before-soal11
            printf '\n%s\n' "$INCLUDE" >> /etc/bind/named.conf.local
        fi

        named-checkconf
        named-checkzone "$ZONE" "$ZONE_FILE"
        dns_service restart

        echo "DNS Master Utahime siap."
        ;;

    bump)
        old_serial=$(awk '/; serial/ {print $1; exit}' "$ZONE_FILE")

        case "$old_serial" in
            ''|*[!0-9]*)
                echo "Serial SOA tidak dapat dibaca." >&2
                exit 1
                ;;
        esac

        new_serial=$((old_serial + 1))

        cp -p "$ZONE_FILE" \
            "/root/db.jujutsu.k05.com.before-serial-$old_serial"

        sed -i \
            "s/^[[:space:]]*$old_serial[[:space:]]*; serial$/    $new_serial ; serial/" \
            "$ZONE_FILE"

        named-checkzone "$ZONE" "$ZONE_FILE"
        rndc reload "$ZONE" || dns_service restart

        echo "Serial Utahime: $old_serial -> $new_serial"
        ;;

    start)
        dns_service start
        ;;

    hook)
        if [ ! -f /root/init.sh ]; then
            echo "/root/init.sh tidak ditemukan." >&2
            exit 1
        fi

        if grep -Eq '^[[:space:]]*(exit|exec)([[:space:]]|$)' /root/init.sh; then
            echo "init.sh memiliki exit/exec. Periksa sebelum menambahkan hook." >&2
            exit 1
        fi

        if ! grep -Fq 'sh /root/soal_11.sh start' /root/init.sh; then
            cp -p /root/init.sh /root/init.sh.before-soal11
            printf '\nsh /root/soal_11.sh start\n' >> /root/init.sh
        fi

        echo "Hook startup Master siap."
        ;;

    *)
        echo "Penggunaan:"
        echo "sh /root/soal_11.sh setup"
        echo "sh /root/soal_11.sh bump"
        echo "sh /root/soal_11.sh start"
        echo "sh /root/soal_11.sh hook"
        exit 2
        ;;
esac
    ;;
  shoko)
    # DNS Slave; setup, start, hook
ZONE_CONF="/etc/bind/soal11-jujutsu.conf"

dns_service() {
    if [ -x /etc/init.d/bind9 ]; then
        service bind9 "$1"
    else
        service named "$1"
    fi
}

case "${1:-setup}" in
    setup)
        if ! command -v named >/dev/null 2>&1; then
            apt-get install -y bind9 bind9-utils
        fi

        cat > "$ZONE_CONF" <<'CONF'
zone "jujutsu.k05.com" {
    type slave;
    masters { 10.66.1.2; };
    file "/var/cache/bind/db.jujutsu.k05.com";
    allow-query { any; };
};
CONF

        INCLUDE='include "/etc/bind/soal11-jujutsu.conf";'

        if ! grep -Fqx "$INCLUDE" /etc/bind/named.conf.local; then
            cp -p /etc/bind/named.conf.local \
                /root/named.conf.local.before-soal11
            printf '\n%s\n' "$INCLUDE" >> /etc/bind/named.conf.local
        fi

        named-checkconf
        dns_service restart

        echo "Slave siap; menunggu zona dari 10.66.1.2."
        ;;

    start)
        dns_service start
        ;;

    hook)
        if [ ! -f /root/init.sh ]; then
            echo "/root/init.sh tidak ditemukan." >&2
            exit 1
        fi

        if grep -Eq '^[[:space:]]*(exit|exec)([[:space:]]|$)' /root/init.sh; then
            echo "init.sh memiliki exit/exec. Periksa sebelum menambahkan hook." >&2
            exit 1
        fi

        if ! grep -Fq 'sh /root/soal_11.sh start' /root/init.sh; then
            cp -p /root/init.sh /root/init.sh.before-soal11
            printf '\nsh /root/soal_11.sh start\n' >> /root/init.sh
        fi

        echo "Hook startup Slave siap."
        ;;

    *)
        echo "Penggunaan:"
        echo "sh /root/soal_11.sh setup"
        echo "sh /root/soal_11.sh start"
        echo "sh /root/soal_11.sh hook"
        exit 2
        ;;
esac
    ;;
  itadori)
    # Query SOA/NS/A pada kedua DNS
if ! command -v dig >/dev/null 2>&1; then
    cp -p /etc/resolv.conf /root/resolv.conf.before-soal11
    printf 'nameserver 192.168.122.1\n' > /etc/resolv.conf

    if ! apk add --no-cache bind-tools; then
        cp -p /root/resolv.conf.before-soal11 /etc/resolv.conf
        exit 1
    fi

    cp -p /root/resolv.conf.before-soal11 /etc/resolv.conf
fi

for server in 10.66.1.2 10.66.1.3; do
    echo
    echo "===== DNS SERVER $server ====="

    dig @"$server" jujutsu.k05.com SOA \
        +time=2 +tries=1 +noall +comments +answer

    dig @"$server" jujutsu.k05.com NS \
        +time=2 +tries=1 +noall +comments +answer

    dig @"$server" utahime.jujutsu.k05.com A \
        +time=2 +tries=1 +noall +answer

    dig @"$server" shoko.jujutsu.k05.com A \
        +time=2 +tries=1 +noall +answer
done
    ;;
  *)
    echo "Soal 11: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
