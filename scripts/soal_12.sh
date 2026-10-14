#!/bin/sh
set -eu
# Soal 12 - K05 (10.66). Salin ke /root/soal_12.sh pada node terkait.
# Tiap bagian dipilih dari hostname; jalankan argumen sesuai README.

case "$(hostname)" in
  utahime)
    # A, CNAME, PTR, forwarder; bergantung pada Soal 11
FORWARD_ZONE=/etc/bind/db.jujutsu.k05.com
REVERSE_ZONE=/etc/bind/db.1.66.10
REVERSE_CONF=/etc/bind/soal12-reverse.conf
OPTIONS=/etc/bind/named.conf.options
OPTIONS_NEW=/root/named.conf.options.soal12.new

[ -f "$FORWARD_ZONE" ] || {
    echo "Zona nomor 11 tidak ditemukan: $FORWARD_ZONE" >&2
    exit 1
}

# Periksa aturan resolver yang sudah ada sebelum mengedit options.
if ! grep -Fq '// soal12 forwarder' "$OPTIONS"; then
    if grep -Eq '^[[:space:]]*(forwarders|forward|recursion|allow-recursion|allow-query-cache)[[:space:]]' "$OPTIONS"; then
        echo "named.conf.options sudah memiliki aturan resolver aktif." >&2
        echo "Periksa file tersebut sebelum melanjutkan; tidak ada options yang ditimpa." >&2
        exit 1
    fi
fi

# Pertahankan zona nomor 11, tambahkan record yang diminta nomor 12.
if ! grep -Eq '^@[[:space:]]+IN[[:space:]]+A[[:space:]]+10\.66\.1\.4([[:space:]]|$)' "$FORWARD_ZONE"; then
    if grep -Eq '^@[[:space:]]+IN[[:space:]]+A[[:space:]]+' "$FORWARD_ZONE"; then
        echo "A record apex sudah ada tetapi bukan 10.66.1.4; hentikan." >&2
        exit 1
    fi
    cp -p "$FORWARD_ZONE" /root/db.jujutsu.k05.com.before-soal12
    printf '\n@ IN A 10.66.1.4\n' >> "$FORWARD_ZONE"
fi

if ! grep -Eq '^www[[:space:]]+IN[[:space:]]+CNAME[[:space:]]+jujutsu\.k05\.com\.' "$FORWARD_ZONE"; then
    if grep -Eq '^www[[:space:]]+IN[[:space:]]+' "$FORWARD_ZONE"; then
        echo "Record www sudah ada dengan nilai lain; hentikan." >&2
        exit 1
    fi
    printf 'www IN CNAME jujutsu.k05.com.\n' >> "$FORWARD_ZONE"
fi

# Reverse zone: 10.66.1.4 -> jujutsu.k05.com.
if [ ! -f "$REVERSE_ZONE" ]; then
    cat > "$REVERSE_ZONE" <<'ZONE'
$TTL 300
@ IN SOA utahime.jujutsu.k05.com. hostmaster.jujutsu.k05.com. (
    2026101401 ; serial
    300        ; refresh
    60         ; retry
    1209600    ; expire
    300        ; negative cache TTL
)
@ IN NS utahime.jujutsu.k05.com.
@ IN NS shoko.jujutsu.k05.com.
4 IN PTR jujutsu.k05.com.
ZONE
fi

if [ ! -f "$REVERSE_CONF" ]; then
    cat > "$REVERSE_CONF" <<'CONF'
zone "1.66.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.1.66.10";
    notify yes;
    also-notify { 10.66.1.3; };
    allow-transfer { 10.66.1.3; };
    allow-query { any; };
};
CONF
fi

INCLUDE='include "/etc/bind/soal12-reverse.conf";'
if ! grep -Fqx "$INCLUDE" /etc/bind/named.conf.local; then
    cp -p /etc/bind/named.conf.local /root/named.conf.local.before-soal12
    printf '\n%s\n' "$INCLUDE" >> /etc/bind/named.conf.local
fi

# Sisipkan aturan ke dalam options yang sudah ada.
if ! grep -Fq '// soal12 forwarder' "$OPTIONS"; then
    cp -p "$OPTIONS" /root/named.conf.options.before-soal12
    awk '
        /^[[:space:]]*options[[:space:]]*\{/ {
            inside=1
            depth=1
            print
            next
        }
        inside {
            clean=$0
            sub(/\/\/.*/, "", clean)
            opens=gsub(/\{/, "{", clean)
            closes=gsub(/\}/, "}", clean)
            if (depth + opens - closes == 0) {
                print "    // soal12 forwarder"
                print "    recursion yes;"
                print "    allow-recursion { localhost; 10.66.0.0/16; };"
                print "    allow-query-cache { localhost; 10.66.0.0/16; };"
                print "    forwarders { 192.168.122.1; };"
                print "    forward only;"
                added=1
                inside=0
            } else {
                depth += opens - closes
            }
        }
        { print }
        END { if (added != 1) exit 1 }
    ' "$OPTIONS" > "$OPTIONS_NEW"
    cp -p "$OPTIONS_NEW" "$OPTIONS"
fi

named-checkconf
named-checkzone jujutsu.k05.com "$FORWARD_ZONE"
named-checkzone 1.66.10.in-addr.arpa "$REVERSE_ZONE"

service named restart

# Serial forward harus naik agar Shoko mengambil A dan CNAME terbaru.
sh /root/soal_11.sh bump

echo "Nomor 12 Utahime selesai dikonfigurasi."
    ;;
  shoko)
    # Reverse zone slave
CONF=/etc/bind/soal12-reverse.conf

if [ ! -f "$CONF" ]; then
    cat > "$CONF" <<'ZONE'
zone "1.66.10.in-addr.arpa" {
    type slave;
    masters { 10.66.1.2; };
    file "/var/cache/bind/db.1.66.10";
    allow-query { any; };
};
ZONE
fi

INCLUDE='include "/etc/bind/soal12-reverse.conf";'
if ! grep -Fqx "$INCLUDE" /etc/bind/named.conf.local; then
    cp -p /etc/bind/named.conf.local /root/named.conf.local.before-soal12
    printf '\n%s\n' "$INCLUDE" >> /etc/bind/named.conf.local
fi

named-checkconf
service named restart
echo "Shoko siap menerima reverse zone dari Utahime."
    ;;
  itadori)
    # Uji records atau internet
case "${1:-}" in
    records)
        echo "=== A DOMAIN UTAMA: UTAHIME ==="
        dig @10.66.1.2 jujutsu.k05.com A +norecurse +short

        echo "=== CNAME WWW: UTAHIME ==="
        dig @10.66.1.2 www.jujutsu.k05.com CNAME +norecurse +short

        echo "=== PTR GOJO: UTAHIME ==="
        dig @10.66.1.2 -x 10.66.1.4 +norecurse +short

        echo "=== PTR GOJO: SHOKO ==="
        dig @10.66.1.3 -x 10.66.1.4 +norecurse +short
        ;;

    internet)
        echo "=== RESOLVER CLIENT ==="
        cat /etc/resolv.conf

        echo "=== DOMAIN INTERNET MELALUI UTAHIME ==="
        dig @10.66.1.2 google.com A +time=3 +tries=1 \
            +noall +comments +answer

        echo "=== PING DOMAIN INTERNET DARI CLIENT ==="
        ping -c 3 google.com
        ;;

    *)
        echo "Pakai: sh /root/soal12-test.sh records|internet" >&2
        exit 2
        ;;
esac
    ;;
  *)
    echo "Soal 12: node $(hostname) tidak dipakai untuk langkah ini" >&2
    exit 2
    ;;
esac
