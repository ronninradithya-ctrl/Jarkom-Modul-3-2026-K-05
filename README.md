# PRAKTIKUM JARKOM MODUL 3 KELOMPOK K05 - 2026

## Anggota Kelompok

| Nama | NRP |
| --- | --- |
| Ronnin Raditya Putra Purbono | 5027251119 |
| Keisya Halimah Mulia | 5027251068 |

## Daftar Isi

- [Soal 1](#1-konfigurasi-ip-address-routing-nat-dan-konektivitas-dasar) — Konfigurasi IP Address, Routing, NAT, dan Konektivitas Dasar
- [Soal 2](#2-instalasi-dan-konfigurasi-dhcp-server-pada-tengen) — Instalasi dan Konfigurasi DHCP Server pada Tengen
- [Soal 3](#3-konfigurasi-dhcp-relay-pada-jichi) — Konfigurasi DHCP Relay pada Jichi
- [Soal 4](#4-pembagian-dua-dhcp-pool-pada-network-2) — Pembagian Dua DHCP Pool pada Network 2
- [Soal 5](#5-pengaturan-short-lease-dan-long-lease-pada-network-3) — Pengaturan Short Lease dan Long Lease pada Network 3
- [Soal 6](#6-dhcp-static-lease-untuk-kugisaki) — DHCP Static Lease untuk Kugisaki
- [Soal 7](#7-audit-ip-address-gateway-dns-dan-dhcp-lease) — Audit IP Address, Gateway, DNS, dan DHCP Lease
- [Soal 8](#8-packet-capture-dan-analisis-proses-dhcp-dora) — Packet Capture dan Analisis Proses DHCP DORA
- [Soal 9](#9-simulasi-gangguan-serta-pemulihan-dhcp-relay) — Simulasi Gangguan serta Pemulihan DHCP Relay
- [Soal 10](#10-autostart-dhcp-server-dan-dhcp-relay-setelah-restart) — Autostart DHCP Server dan DHCP Relay Setelah Restart

## Struktur Repository dan Penampilan Screenshot

```text
Jarkom-Modul-3-2026-K-05/
├── README.md
├── assets/
│   ├── soal-1-ss1-jichi-routing-nat-internet.png
│   ├── soal-1-ss2-jichi-routing-nat-verifikasi.png
│   ├── ... (seluruh 37 screenshot bukti Soal 1–10)
│   └── soal-10-ss5-kugisaki-fixed-ip-audit-after-restart.png
├── scripts/              # Opsional: masukkan script /root asli dari tiap node
└── project/              # Opsional: file ekspor project GNS3
```

Seluruh screenshot dalam laporan menggunakan path relatif `assets/nama-file.png`. Dengan demikian gambar akan ditampilkan otomatis ketika `README.md` dan folder `assets/` diunggah bersama ke GitHub. Penamaan gambar memakai pola `soal-N-ssM-deskripsi.png` dan urutan `ss1`, `ss2`, dan seterusnya dimulai kembali pada tiap soal.

## Topologi Jaringan

Berikut disediakan ruang untuk screenshot topologi GNS3. Bagian ini sengaja **belum diisi dengan gambar** karena screenshot topologi akan ditambahkan setelah praktikum.

```text
╔════════════════════════════════════════════════════════════════════╗
║                                                                    ║
║                                                                    ║
║                                                                    ║
║                     SCREENSHOT TOPOLOGI GNS3                      ║
║                                                                    ║
║                         (BELUM DITAMBAHKAN)                       ║
║                                                                    ║
║                                                                    ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

Setelah screenshot tersedia, simpan file sebagai `assets/topologi-modul-3.png` dan ganti blok placeholder di atas dengan:

```markdown
![Topologi Jaringan Praktikum Modul 3 K05](assets/topologi-modul-3.png)
```

## Laporan

Praktikum Modul 3 Komunikasi Data & Jaringan Komputer 2026 mengangkat skenario **Curtain Protocol: Shibuya Incident**, yaitu pemulihan jaringan dan layanan Jujutsu High. Pada Soal 1–10, pekerjaan berfokus pada routing dan source NAT di **Jichi**, server DHCP di **Tengen**, DHCP Relay lintas-subnet, pengaturan pool/kelas klien, audit lease, analisis paket DHCP, simulasi kegagalan relay, dan keberlangsungan layanan setelah restart.

### Informasi jaringan dan konvensi

| Parameter | Konfigurasi |
| --- | --- |
| Kelompok | K05 |
| Prefix IP internal | `10.66` |
| Subnet mask tiap segmen | `255.255.255.0` atau `/24` |
| Network 1 (DMZ) | `10.66.1.0/24` — gateway Jichi `10.66.1.1` |
| Network 2 (Divisi A) | `10.66.2.0/24` — gateway Jichi `10.66.2.1` |
| Network 3 (Divisi B) | `10.66.3.0/24` — gateway Jichi `10.66.3.1` |
| Network 4 (Data Center) | `10.66.4.0/24` — gateway Jichi `10.66.4.1` |
| Router / DHCP Relay | `jichi` |
| DHCP Server | `tengen` — `10.66.4.10` |
| DNS yang dibagikan DHCP | `10.66.1.2` (Utahime), `10.66.1.3` (Shoko) |
| Domain search | `k05.com` |
| WAN NAT GNS3 | Interface `jichi:eth0`, gateway `192.168.122.1` |
| Lokasi script pada node | Direktori `/root` |
| Image node server/router | `ardhptr21/debinet:latest` |
| Image node client | `ardhptr21/alpinet:latest` |

Pada bagian “Hasil Pengujian”, nilai yang disebutkan mengikuti screenshot dan log praktikum yang tersedia. Contoh sintaks konfigurasi atau command tambahan diberi konteks sebagai **penjelasan**, **contoh**, atau **cara validasi**, bukan diklaim sebagai salinan persis script `/root` apabila file aslinya belum tersedia. File script harus disalin langsung dari node GNS3 bila diperlukan sebagai artefak konfigurasi resmi.

---

# 1. Konfigurasi IP Address, Routing, NAT, dan Konektivitas Dasar

## Soal

> Ketika Curtain menutup Shibuya, jalur komunikasi antar zona Jujutsu High terputus. Pulihkan konektivitas dasar dengan mengonfigurasi jichi: eth0 memperoleh WAN dari NAT, sedangkan eth1–eth4 menjadi gateway Network 1–4 sesuai tabel pemetaan. Aktifkan IPv4 forwarding dan source NAT, lalu tetapkan IP statis host infrastruktur sesuai tabel spesifikasi. Buktikan konektivitas setiap host ke gateway dan akses eksternal dari host yang relevan.

## Mengapa Script No. 1 Dibuat Seperti Ini

| Bagian script/konfigurasi | Fungsi | Alasan digunakan |
| --- | --- | --- |
| `ip link set <interface> up` | Mengaktifkan antarmuka | IP yang telah diatur tidak bermanfaat bila link tidak aktif. |
| `ip addr add` / `ip addr replace` | Mengatur IPv4 dan prefix `/24` | Memisahkan empat domain broadcast dan memastikan seluruh host memakai segmentasi yang tepat. |
| `ip route` | Memeriksa/mengatur rute termasuk default gateway | Host internal perlu mengirim trafik lintas-subnet melalui Jichi; Jichi mengirim trafik eksternal ke NAT. |
| `sysctl -w net.ipv4.ip_forward=1` | Mengaktifkan forwarding | Kernel harus diizinkan meneruskan paket antar-interface, bukan hanya menerima paket untuk Jichi sendiri. |
| `iptables -t nat ... MASQUERADE` | Source NAT keluar melalui `eth0` | Alamat privat `10.66.x.x` perlu diterjemahkan saat mencapai jaringan luar. |
| `ping` ke gateway atau `8.8.8.8` | Uji konektivitas Layer 3 | Membuktikan akses gateway lokal dan koneksi internet berbasis IP tanpa bergantung pada DNS. |

## Analisis Kebutuhan dan Skema Jaringan

Soal menggabungkan tiga hal yang saling bergantung: pengalamatan IP, routing antarsubnet, dan akses internet melalui NAT. Sesuai rancangan, `jichi` mempunyai lima interface: satu interface menuju NAT (`eth0`) dan empat interface sebagai gateway tiap jaringan internal (`eth1` sampai `eth4`). Client tidak perlu memiliki tabel routing untuk semua subnet, karena cukup memakai default gateway yang merupakan IP Jichi pada segmennya.

### Pembagian interface dan gateway Jichi

| Interface Jichi | Segmen | IP gateway |
| --- | --- | --- |
| `eth0` | WAN/NAT GNS3 | IP WAN dari NAT; next hop `192.168.122.1` |
| `eth1` | Network 1 / DMZ | `10.66.1.1/24` |
| `eth2` | Network 2 / Divisi A | `10.66.2.1/24` |
| `eth3` | Network 3 / Divisi B | `10.66.3.1/24` |
| `eth4` | Network 4 / Data Center | `10.66.4.1/24` |

### Host infrastruktur statis yang dibuktikan

| Host | IP Address | Default gateway | Peran |
| --- | --- | --- | --- |
| `utahime` | `10.66.1.2/24` | `10.66.1.1` | DNS Master, Network 1 |
| `shoko` | `10.66.1.3/24` | `10.66.1.1` | DNS Slave, Network 1 |
| `tengen` | `10.66.4.10/24` | `10.66.4.1` | DHCP Server, Network 4 |

Alamat `jichi:eth0` diberikan oleh NAT melalui DHCP. Karena dapat berubah menurut lingkungan GNS3, laporan ini tidak mengunci satu angka IP WAN; yang relevan ialah bahwa interface berada di segmen `192.168.122.0/24` dan default route menuju `192.168.122.1`.

## Command yang Dijalankan dan Konfigurasi

### A. Mengaktifkan dan menyiapkan interface Jichi

Contoh perintah inti yang merepresentasikan konfigurasi interface LAN pada Jichi:

```bash
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up
ip link set eth4 up

ip addr replace 10.66.1.1/24 dev eth1
ip addr replace 10.66.2.1/24 dev eth2
ip addr replace 10.66.3.1/24 dev eth3
ip addr replace 10.66.4.1/24 dev eth4
```

Untuk interface WAN, alamat NAT diperoleh sesuai skenario DHCP GNS3. Pengaturan routing keluar memanfaatkan next hop `192.168.122.1`.

### B. Mengaktifkan forwarding dan source NAT

```bash
sysctl -w net.ipv4.ip_forward=1

# Bentuk aturan yang digunakan untuk internet keluar:
iptables -t nat -A POSTROUTING -s 10.66.0.0/16 -o eth0 -j MASQUERADE
```

**Penjelasan:** `-t nat` memilih tabel translasi alamat, `POSTROUTING` memproses paket sesaat sebelum keluar interface, `-s 10.66.0.0/16` mencakup prefix seluruh LAN internal, `-o eth0` membatasi operasi pada jalur NAT, dan `MASQUERADE` mengganti sumber paket memakai alamat interface WAN. Jika memasukkan command ini berulang kali, lakukan pemeriksaan terlebih dahulu agar aturan NAT tidak terduplikasi.

### C. Konfigurasi host infrastruktur

Sebagai contoh, `utahime` menggunakan:

```bash
ip link set eth0 up
ip addr replace 10.66.1.2/24 dev eth0
ip route replace default via 10.66.1.1 dev eth0
```

Host Shoko dan Tengen memakai pola yang sama dengan alamat IP/gateway sesuai tabel. Script dan file konfigurasi yang digunakan pada saat praktikum berada di direktori `/root` node masing-masing.

## Validasi

Di Jichi, pemeriksaan yang relevan adalah:

```bash
ip -br addr
ip route
sysctl net.ipv4.ip_forward
iptables -t nat -L POSTROUTING -n -v
ping -c 3 8.8.8.8
```

Di Utahime, Shoko, dan Tengen:

```bash
hostname
ip -br addr
ip route
ping -c 3 <IP-GATEWAY-LOKAL>
ping -c 3 8.8.8.8
```

**Ekspektasi validasi:** setiap interface LAN mempunyai IP yang benar, semua host memiliki default route sesuai network, `ip_forward = 1`, ada aturan NAT, serta `ping` menuju gateway/internet menghasilkan balasan tanpa packet loss.

## Hasil Pengujian dan Analisis

Bukti Jichi menampilkan interface internal yang mengikuti rencana pengalamatan, routing, forwarding, NAT, dan ping keluar yang berhasil. Bukti pada Utahime, Shoko, serta Tengen menunjukkan gateway masing-masing dan konektivitas IP berhasil. Ini penting karena server DHCP pada nomor berikutnya akan diletakkan di Network 4, sedangkan request berasal dari Network 2 dan 3.

## Bukti Screenshot

### Screenshot 1 — Jichi: konfigurasi jaringan dan akses internet

Menunjukkan status interface router, routing, forwarding/NAT, serta pengujian koneksi keluar.

![Soal 1 - Jichi: konfigurasi jaringan dan akses internet](assets/soal-1-ss1-jichi-routing-nat-internet.png)

**Analisis bukti:** Jichi berfungsi sebagai titik pertemuan empat LAN dan satu WAN NAT; keberhasilan ping IP publik mengindikasikan jalur eksternal tersedia.

### Screenshot 2 — Jichi: verifikasi routing dan NAT

Tangkapan layar lanjutan konfigurasi Jichi untuk menguatkan hasil pemeriksaan di router.

![Soal 1 - Jichi: verifikasi routing dan NAT](assets/soal-1-ss2-jichi-routing-nat-verifikasi.png)

**Analisis bukti:** Adanya rute lokal untuk empat subnet dan aturan keluar diperlukan sebelum layanan lintas jaringan diuji.

### Screenshot 3 — Utahime: IP, gateway, dan konektivitas

Memuat pemeriksaan IP host `utahime` dan uji gateway/internet.

![Soal 1 - Utahime: IP, gateway, dan konektivitas](assets/soal-1-ss3-utahime-ip-gateway-internet.png)

**Analisis bukti:** Utahime berada di Network 1, yaitu subnet `10.66.1.0/24` dengan next hop `10.66.1.1`.

### Screenshot 4 — Shoko: IP, gateway, dan konektivitas

Memuat pemeriksaan IP host `shoko` dan uji gateway/internet.

![Soal 1 - Shoko: IP, gateway, dan konektivitas](assets/soal-1-ss4-shoko-ip-gateway-internet.png)

**Analisis bukti:** Shoko menggunakan subnet DMZ yang sama dengan Utahime, tetapi memiliki IP berbeda agar tidak bentrok.

### Screenshot 5 — Tengen: IP, gateway, dan konektivitas

Memuat pemeriksaan IP host `tengen` dan uji gateway/internet.

![Soal 1 - Tengen: IP, gateway, dan konektivitas](assets/soal-1-ss5-tengen-ip-gateway-internet.png)

**Analisis bukti:** Tengen berada pada `10.66.4.10/24`; keterjangkauan Network 4 dibutuhkan agar Jichi dapat meneruskan paket DHCP ke server.

## Kesimpulan

Routing dasar pada Jichi, penetapan IP statis host infrastruktur, pengaktifan forwarding, dan source NAT telah diverifikasi dengan bukti akses gateway dan koneksi eksternal. Kondisi ini menjadi prasyarat untuk mendukung layanan DHCP lintas subnet pada nomor selanjutnya.

---

# 2. Instalasi dan Konfigurasi DHCP Server pada Tengen

## Soal

> Tengen, penjaga pusat distribusi di Data Center, harus mengambil alih pengalokasian alamat bagi wilayah yang membutuhkan konfigurasi dinamis. Konfigurasikan isc-dhcp-server pada [PREFIX IP].4.10. Deklarasikan Network 4 ([PREFIX IP].4.0/24) sebagai subnet lokal tanpa pool dinamis, lalu siapkan scope DHCP untuk Network 2 ([PREFIX IP].2.0/24) dan Network 3 ([PREFIX IP].3.0/24). Validasi konfigurasi dan pastikan service aktif tanpa error “No subnet declaration”.

## Mengapa Script No. 2 Dibuat Seperti Ini

| Bagian konfigurasi | Fungsi | Alasan |
| --- | --- | --- |
| `isc-dhcp-server` | Daemon pembagi konfigurasi IP secara dinamis | Tengen menjadi pusat distribusi DHCP untuk Divisi A dan Divisi B. |
| `INTERFACESv4="eth0"` | Memilih interface yang mendengarkan DHCP | Tengen hanya mempunyai interface layanan di Data Center. |
| Deklarasi `subnet 10.66.4.0/24` tanpa `range` | Mengenalkan subnet tempat server berdiri | Menghindari error `No subnet declaration for eth0` dan mencegah distribusi dinamis pada Data Center. |
| Deklarasi `subnet 10.66.2.0/24` dan `10.66.3.0/24` | Menyediakan scope subnet klien remote | Server harus tahu subnet tujuan ketika request diteruskan oleh DHCP Relay. |
| `dhcpd -t -cf /etc/dhcp/dhcpd.conf` | Menguji validitas konfigurasi | Syntax error dicegah sebelum service dijalankan. |
| `ss -lunp` | Memeriksa UDP port 67 | Membuktikan daemon benar-benar siap menerima paket DHCP. |

## Penjelasan dan Alur Kerja DHCP Server

Tengen adalah node Data Center `10.66.4.10`. Tidak semua client berada satu segmen dengan Tengen. Oleh karena itu server harus mendefinisikan subnet **lokal** `10.66.4.0/24` sekaligus dua subnet **remote** `10.66.2.0/24` dan `10.66.3.0/24`. Pembagian rentang alamat per kelas dilakukan lebih rinci pada Soal 4 dan Soal 5.

`isc-dhcp-server` menggunakan UDP 67 untuk menerima request, sementara client memakai UDP 68. Agar server tidak salah membaca interface lokal, `INTERFACESv4` diset ke `eth0`. Network 4 sengaja tidak mendapat pool karena Data Center menggunakan pengalamatan statis sesuai desain.

## Command yang Dijalankan

### A. Instalasi paket pada Tengen

```bash
# Pada node tengen
printf 'nameserver 192.168.122.1\n' > /etc/resolv.conf
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server
```

DNS `192.168.122.1` digunakan selama tahap persiapan paket. Ini berbeda dengan resolver internal yang nantinya dibagikan kepada client melalui DHCP.

### B. Menentukan interface layanan

Berkas `/etc/default/isc-dhcp-server` berisi konfigurasi berikut:

```bash
INTERFACESv4="eth0"
INTERFACESv6=""
```

### C. Deklarasi subnet dasar

Cuplikan inti `/etc/dhcp/dhcpd.conf` berikut memperlihatkan struktur subnet yang disyaratkan:

```conf
authoritative;
ddns-update-style none;

default-lease-time 3600;
max-lease-time 7200;

subnet 10.66.4.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.66.4.255;
    option routers 10.66.4.1;
    # Tidak ada range dinamis untuk Data Center.
}

subnet 10.66.2.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.66.2.255;
    option routers 10.66.2.1;
    option domain-name-servers 10.66.1.2, 10.66.1.3;
    option domain-name "k05.com";
    option domain-search "k05.com";
    # Pool berdasarkan DHCP class ditambahkan pada Soal 4.
}

subnet 10.66.3.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.66.3.255;
    option routers 10.66.3.1;
    option domain-name-servers 10.66.1.2, 10.66.1.3;
    option domain-search "k05.com";
    # Pool khusus masa lease ditambahkan pada Soal 5.
}
```

> **Catatan tahapan:** cuplikan di atas adalah **scope dasar No. 2**. Pada kondisi akhir praktikum, `/etc/dhcp/dhcpd.conf` juga memiliki tambahan class, pool, reservation, dan lease-time dari No. 4–6. Jangan menimpa konfigurasi akhir dengan cuplikan awal.

## Validasi

```bash
# Pada tengen
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server status
pgrep -a dhcpd
ss -lunp | grep ':67'
grep -n 'subnet 10.66' /etc/dhcp/dhcpd.conf
```

**Ekspektasi:** pemeriksaan konfigurasi selesai tanpa error, proses `dhcpd` ditemukan, server mendengarkan UDP 67, dan tiga subnet telah dideklarasikan. Error `No subnet declaration` tidak muncul.

## Hasil Pengujian dan Analisis

Screenshot menampilkan service DHCP dalam keadaan berjalan, proses `dhcpd`, dan listener di port 67. Cuplikan file konfigurasi memuat Network 4 tanpa pool, Network 2, dan Network 3 beserta gateway dan opsi DNS yang relevan. Dengan demikian server siap menerima request yang akan diteruskan oleh Jichi.

## Bukti Screenshot

### Screenshot 1 — Tengen: DHCP Server aktif dan port UDP 67

Menunjukkan status proses layanan DHCP dan socket yang mendengarkan port 67.

![Soal 2 - Tengen: DHCP Server aktif dan port UDP 67](assets/soal-2-ss1-tengen-dhcp-service-port67.png)

**Analisis bukti:** Status layanan berjalan dan port tersedia merupakan dua bukti berbeda: konfigurasi valid saja belum menjamin daemon benar-benar aktif.

### Screenshot 2 — Tengen: konfigurasi subnet Network 2, 3, dan 4

Tangkapan isi `dhcpd.conf` yang memperlihatkan deklarasi subnet sesuai topologi.

![Soal 2 - Tengen: konfigurasi subnet Network 2, 3, dan 4](assets/soal-2-ss2-tengen-dhcp-subnet-konfigurasi.png)

**Analisis bukti:** Network 4 harus dideklarasikan tanpa range agar server mengenali LAN sendiri, sedangkan Network 2/3 disiapkan untuk request melalui relay.

## Kesimpulan

Server DHCP terpusat di Tengen berhasil dipersiapkan dan diuji, mencakup deklarasi subnet yang benar, status layanan aktif, dan port DHCP yang tersedia. Tahap ini menjadi fondasi bagi pengalokasian alamat lintas-subnet.

---

# 3. Konfigurasi DHCP Relay pada Jichi

## Soal

> Permintaan alamat dari Divisi A dan Divisi B tidak dapat menyeberangi subnet secara langsung. Konfigurasikan jichi sebagai DHCP Relay menuju tengen ([PREFIX IP].4.10), menggunakan eth2 untuk Network 2 dan eth3 untuk Network 3. Buktikan bahwa client dari kedua subnet berhasil memperoleh lease melalui relay.

## Mengapa Script No. 3 Dibuat Seperti Ini

| Bagian | Fungsi | Alasan |
| --- | --- | --- |
| `isc-dhcp-relay` / `dhcrelay` | Meneruskan DHCP broadcast antar-subnet | Broadcast Discover tidak melewati router secara biasa. |
| `SERVERS="10.66.4.10"` | Menunjuk alamat Tengen | Semua permintaan alamat dikirim ke satu server pusat. |
| `INTERFACES="eth2 eth3 eth4"` | Mendengarkan sisi client dan server | `eth2` ke Network 2, `eth3` ke Network 3, `eth4` ke Data Center. |
| `pgrep -a dhcrelay` | Memeriksa proses dan argumen aktual | Memastikan relay berjalan menuju tujuan serta interface yang tepat. |
| Field `giaddr` pada request DHCP | Penanda jaringan asal relay | Membantu server memilih scope Network 2 atau Network 3. |

## Penjelasan Teknis

DHCP Discover dikirim client sebagai broadcast. Karena client Itadori/Fushiguro/Zenin/Okkotsu berada di Network 2 dan Ino/Kusakabe/Miwa/Kugisaki berada di Network 3, permintaan mereka tidak langsung mencapai Tengen di Network 4. Jichi memerlukan **DHCP Relay** yang menerima permintaan pada interface segmen asal, kemudian meneruskannya ke `10.66.4.10`.

Relay mengisi alamat gateway relay (`giaddr`) sesuai segmen asal. Sebagai contoh ketika Itadori di Network 2 meminta alamat, relay pada interface `eth2` merepresentasikan jaringan `10.66.2.0/24` dengan `giaddr = 10.66.2.1`. Tengen memakai nilai ini untuk memilih subnet dan pool yang benar, lalu jawaban kembali melalui relay.

## Command dan Konfigurasi

Di Jichi, paket relay dijalankan menggunakan konfigurasi yang terlihat pada bukti:

```bash
# Konfigurasi utama di /etc/default/isc-dhcp-relay
SERVERS="10.66.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
```

Untuk menjalankan atau memeriksa daemon:

```bash
service isc-dhcp-relay restart
pgrep -a dhcrelay
```

Bentuk proses yang terverifikasi selama pengujian lanjutan adalah:

```text
dhcrelay -i eth2 -i eth3 -i eth4 10.66.4.10
```

## Validasi

Pemeriksaan relay pada Jichi:

```bash
cat /etc/default/isc-dhcp-relay
pgrep -a dhcrelay
```

Pemeriksaan lease pada client dapat dilakukan dengan:

```bash
# Pada client Alpinet
udhcpc -i eth0 -q -n
ip -br addr show eth0
ip route
```

**Ekspektasi:** client Network 2 memperoleh IP `10.66.2.x` dengan gateway `10.66.2.1`, sedangkan client Network 3 memperoleh IP `10.66.3.x` dengan gateway `10.66.3.1`. Bukti rinci penerimaan alamat kedua network juga didokumentasikan pada No. 4–7.

## Hasil Pengujian dan Analisis

Jichi memiliki konfigurasi relay menuju Tengen dengan interface `eth2 eth3 eth4`. Kombinasi ini diperlukan agar trafik DHCP dari dua jaringan klien mencapai server di Data Center. Keberhasilan lease di Network 2 dan 3 pada nomor-nomor berikutnya menjadi verifikasi end-to-end alur relay, bukan hanya verifikasi status daemon.

## Bukti Screenshot

### Screenshot 1 — Jichi: konfigurasi DHCP Relay dan proses aktif

Memperlihatkan isi berkas konfigurasi relay serta proses yang mengarah ke `10.66.4.10`.

![Soal 3 - Jichi: konfigurasi DHCP Relay dan proses aktif](assets/soal-3-ss1-jichi-konfigurasi-dhcp-relay.png)

**Analisis bukti:** Kesesuaian interface menentukan apakah relay menerima Discover dari subnet klien yang tepat dan dapat mengirim ke jaringan server.

## Kesimpulan

Jichi menjalankan fungsi DHCP Relay menuju Tengen dan menghubungkan dua subnet client dengan server DHCP terpusat di Network 4. Konfigurasi ini menjadi syarat distribusi lease berdasarkan kelas klien.

---

# 4. Pembagian Dua DHCP Pool pada Network 2

## Soal

> Agar tim Dev dan Support di Divisi A menerima jatah alamat yang berbeda, atur dua pool DHCP pada Network 2. Tetapkan Pool 1 ([PREFIX IP].2.10–[PREFIX IP].2.35) untuk itadori dan fushiguro, serta Pool 2 ([PREFIX IP].2.70–[PREFIX IP].2.95) untuk zenin dan okkotsu. Rentang [PREFIX IP].2.36–[PREFIX IP].2.69 tidak boleh dialokasikan. Karena seluruh client berada pada subnet yang sama, gunakan DHCP class berdasarkan MAC Address atau Client ID untuk memisahkan kedua kelompok.

## Mengapa Dua Pool dan DHCP Class Diperlukan

| Ketentuan | Tujuan | Alasan |
| --- | --- | --- |
| Pool 1 `.2.10–.2.35` | IP khusus Itadori dan Fushiguro | Kedua client tergabung dalam Divisi A kelompok pertama. |
| Pool 2 `.2.70–.2.95` | IP khusus Zenin dan Okkotsu | Kedua client mendapat ruang alamat berbeda meskipun satu subnet. |
| Larangan `.2.36–.2.69` | Rentang tidak boleh diberikan | Mencegah pool melampaui kebijakan alamat yang ditentukan. |
| DHCP class berdasarkan MAC/Client ID | Membedakan request dalam subnet yang sama | Alamat `giaddr` tidak dapat membedakan kelompok, karena keempat client berada di Network 2. |
| `allow members of ...` | Membatasi anggota yang bisa memakai suatu pool | Menjamin anggota Pool 1 tidak menerima alamat Pool 2, begitu pula sebaliknya. |

## Analisis Kebijakan Alokasi Network 2

Network 2 mempunyai alamat subnet `10.66.2.0/24` dengan gateway `10.66.2.1`, broadcast `10.66.2.255`, serta DNS `10.66.1.2` dan `10.66.1.3`. Karena keempat client berada di segmen broadcast yang sama, pemisahan pool tidak dapat mengandalkan interface relay saja. Pembagian dilakukan melalui identitas client seperti MAC address atau Client ID.

### Identitas MAC dan hasil alokasi

| Client | MAC yang dicatat | Pool | IP hasil pengujian | Gateway |
| --- | --- | --- | --- | --- |
| `itadori` | `02:42:82:1c:22:00` | Pool 1 | `10.66.2.10/24` | `10.66.2.1` |
| `fushiguro` | `02:42:f2:4f:86:00` | Pool 1 | `10.66.2.11/24` | `10.66.2.1` |
| `zenin` | `02:42:75:8d:2f:00` | Pool 2 | `10.66.2.70/24` | `10.66.2.1` |
| `okkotsu` | `02:42:3a:94:86:00` | Pool 2 | `10.66.2.71/24` | `10.66.2.1` |

**Penting:** nilai IP pada tabel merupakan hasil lease yang tampak pada bukti, bukan `fixed-address` untuk semua client. Lease dapat berbeda setelah database lease dibersihkan, selama tetap dalam pool yang diizinkan.

## Command dan Konfigurasi

Pada Tengen, file `/etc/dhcp/dhcpd.conf` memuat pemisahan class berbasis hardware address dan rentang yang telah ditetapkan. Berikut **ilustrasi prinsip pemisahan** berdasarkan MAC (bukan salinan literal file konfigurasi asli):

```conf
# Contoh bentuk class berdasarkan hardware (MAC), BUKAN dump file asli.
class "NET2_POOL1" { match hardware; }
subclass "NET2_POOL1" 1:02:42:82:1c:22:00;  # Itadori
subclass "NET2_POOL1" 1:02:42:f2:4f:86:00;  # Fushiguro

class "NET2_POOL2" { match hardware; }
subclass "NET2_POOL2" 1:02:42:75:8d:2f:00;  # Zenin
subclass "NET2_POOL2" 1:02:42:3a:94:86:00;  # Okkotsu
```

> Cuplikan ini adalah **contoh sintaks class/subclass**, bukan salinan pasti konfigurasi Tengen. Angka `1:` menunjukkan hardware type Ethernet yang menjadi bagian dari data `hardware` untuk pencocokan subclass. Untuk dokumentasi yang dapat direproduksi, gunakan **definisi class/subclass asli dari `/etc/dhcp/dhcpd.conf` Tengen**. Prinsipnya ialah pemetaan MAC→kelas lalu pembatasan kelas pada `pool`.

Cuplikan *pool* berikut menunjukkan bagian yang dapat dibandingkan langsung dengan hasil perintah `grep` pada Tengen:

```conf
# Struktur dua pool pada subnet 10.66.2.0/24:
pool {
    range 10.66.2.10 10.66.2.35;
    allow members of "NET2_POOL1";
}
pool {
    range 10.66.2.70 10.66.2.95;
    allow members of "NET2_POOL2";
}
```

Kebijakan ini memastikan tidak ada pernyataan `range` untuk `10.66.2.36–10.66.2.69`.

## Validasi

Pada Tengen:

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
grep -nE 'class|subclass|range 10\.66\.2\.|allow members' /etc/dhcp/dhcpd.conf
service isc-dhcp-server status
```

Pada masing-masing client Network 2:

```bash
hostname
ip -br addr
ip route
```

**Kriteria benar:** tiap anggota Pool 1 memiliki `10.66.2.10–.35`, tiap anggota Pool 2 memiliki `10.66.2.70–.95`, tidak ada anggota yang mendapat `.36–.69`, semua `/24`, dan default gateway `10.66.2.1`.

## Hasil Pengujian dan Analisis

Berdasarkan empat bukti client, distribusi alamat sesuai kebijakan: Itadori dan Fushiguro berada pada rentang Pool 1, sedangkan Zenin dan Okkotsu berada pada rentang Pool 2. File konfigurasi Tengen menunjukkan pembagian kelas/pool yang mengikat alokasi. Kombinasi bukti sisi server dan sisi client mendukung bahwa pembatasan berjalan sesuai tujuan.

## Bukti Screenshot

### Screenshot 1 — Tengen: DHCP class dan dua pool Network 2

Memperlihatkan pembagian kelas client berdasarkan identitas dan penetapan rentang dua pool.

![Soal 4 - Tengen: DHCP class dan dua pool Network 2](assets/soal-4-ss1-tengen-dhcp-pool-class-network2.png)

**Analisis bukti:** Rentang antar-pool tidak saling bersinggungan dan menyisakan ruang `.36–.69` tanpa alokasi dinamis.

### Screenshot 2 — Fushiguro menerima lease Pool 1

Menunjukkan `10.66.2.11/24` dengan default gateway `10.66.2.1`.

![Soal 4 - Fushiguro menerima lease Pool 1](assets/soal-4-ss2-fushiguro-pool1-ip-gateway.png)

**Analisis bukti:** IP berada di `10.66.2.10–.35`, sehingga sesuai kategori Pool 1.

### Screenshot 3 — Itadori menerima lease Pool 1

Menunjukkan `10.66.2.10/24` dengan default gateway `10.66.2.1`.

![Soal 4 - Itadori menerima lease Pool 1](assets/soal-4-ss3-itadori-pool1-ip-gateway.png)

**Analisis bukti:** Bukti klien kedua pada kelas yang sama menunjukkan alokasi dilakukan tanpa konflik IP.

### Screenshot 4 — Zenin menerima lease Pool 2

Menunjukkan `10.66.2.70/24` dengan default gateway `10.66.2.1`.

![Soal 4 - Zenin menerima lease Pool 2](assets/soal-4-ss4-zenin-pool2-ip-gateway.png)

**Analisis bukti:** Nilai berada tepat pada awal rentang Pool 2, bukan Pool 1.

### Screenshot 5 — Okkotsu menerima lease Pool 2

Menunjukkan `10.66.2.71/24` dengan default gateway `10.66.2.1`.

![Soal 4 - Okkotsu menerima lease Pool 2](assets/soal-4-ss5-okkotsu-pool2-ip-gateway.png)

**Analisis bukti:** Alokasi Pool 2 berjalan untuk lebih dari satu MAC dan tidak memakai rentang terlarang.

## Kesimpulan

Pemisahan DHCP berdasarkan identitas client pada Network 2 sesuai dua kebijakan pool. Empat client memperoleh alamat dalam rentang yang benar dan menggunakan gateway Network 2 yang sama.

---

# 5. Pengaturan Short Lease dan Long Lease pada Network 3

## Soal

> Setiap tim lapangan memiliki durasi operasi yang berbeda. Pada Network 3, berikan short lease 30 menit (1800 detik) kepada ino dan kusakabe, serta long lease 12 jam (43200 detik) kepada miwa. Gunakan pool short lease [PREFIX IP].3.10–[PREFIX IP].3.89 dan pool long lease [PREFIX IP].3.100–[PREFIX IP].3.199. Sesuaikan default-lease-time dan max-lease-time untuk setiap kelas client. Berikan pula DHCP options berupa DNS [PREFIX IP].1.2 dan [PREFIX IP].1.3, serta domain-search <xxxx>.com.

## Mengapa Short Lease dan Long Lease Dibedakan

| Pengaturan | Nilai | Tujuan |
| --- | --- | --- |
| Short lease | `1800` detik = 30 menit | Mempercepat daur ulang alamat untuk tim dengan koneksi sementara. |
| Long lease | `43200` detik = 12 jam | Mengurangi kebutuhan renewal untuk terminal yang perlu stabilitas lebih lama. |
| Pool short | `10.66.3.10–10.66.3.89` | Menampung Ino dan Kusakabe. |
| Pool long | `10.66.3.100–10.66.3.199` | Menampung Miwa. |
| `default-lease-time` | Lease default yang ditawarkan | Menentukan lama sewa normal jika client tidak meminta nilai lain. |
| `max-lease-time` | Batas atas lease | Menjaga request durasi lease tidak melewati kebijakan pool. |
| DHCP option DNS + domain search | Utahime, Shoko, `k05.com` | Membentuk konfigurasi resolusi nama yang konsisten. |

## Analisis Kebutuhan Network 3

Network 3 memiliki gateway `10.66.3.1/24`, broadcast `10.66.3.255`, dan dua kelas lease yang berbeda. Pemisahan berdasarkan kelas client memastikan Ino serta Kusakabe memperoleh lease singkat, sementara Miwa memiliki lease panjang. Subnet tetap sama; yang berbeda adalah rentang pool dan durasi sewa.

### Alokasi yang terverifikasi

| Client | Kebijakan | Pool | IP hasil | Gateway |
| --- | --- | --- | --- | --- |
| `ino` | Short lease 1800 detik | `.3.10–.3.89` | `10.66.3.10/24` | `10.66.3.1` |
| `kusakabe` | Short lease 1800 detik | `.3.10–.3.89` | `10.66.3.11/24` | `10.66.3.1` |
| `miwa` | Long lease 43200 detik | `.3.100–.3.199` | `10.66.3.100/24` | `10.66.3.1` |

## Command dan Konfigurasi

Prinsip opsi DHCP untuk client Network 3:

```conf
option routers 10.66.3.1;
option broadcast-address 10.66.3.255;
option subnet-mask 255.255.255.0;
option domain-name-servers 10.66.1.2, 10.66.1.3;
option domain-search "k05.com";
```

Cuplikan struktur kebijakan berikut menunjukkan hubungan antara kelas dan lease time, bukan pengganti file asli `dhcpd.conf`:

```conf
# Kelompok short lease
pool {
    range 10.66.3.10 10.66.3.89;
    allow members of "NET3_SHORT";
    default-lease-time 1800;
    max-lease-time 1800;
}

# Kelompok long lease
pool {
    range 10.66.3.100 10.66.3.199;
    allow members of "NET3_LONG";
    default-lease-time 43200;
    max-lease-time 43200;
}
```

Identitas MAC/Client ID untuk masing-masing class diproses pada definisi class DHCP di Tengen. Pastikan dua pool tersebut terikat ke kelas yang tepat.

## Validasi

Di Tengen:

```bash
grep -nE 'NET3_SHORT|NET3_LONG|range 10\.66\.3\.|default-lease-time|max-lease-time' /etc/dhcp/dhcpd.conf
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

Pada masing-masing client:

```bash
hostname
ip -br addr
ip route
cat /etc/resolv.conf
```

**Ekspektasi:** Ino dan Kusakabe berada di rentang short lease; Miwa berada di rentang long lease; seluruhnya menggunakan gateway `10.66.3.1`, DNS `10.66.1.2` dan `10.66.1.3`, serta search `k05.com`. Waktu lease aktual divalidasi dari pesan DHCP (misalnya `Lease-Time` pada paket) atau berkas lease, bukan dari IP address saja.

## Hasil Pengujian dan Analisis

Screenshot Tengen menampilkan pembagian pool Network 3, sedangkan tiga bukti client menunjukkan IP dan gateway yang sesuai. `resolv.conf` pada client juga memuat DNS dan search domain yang diminta. Sisi server menjadi sumber pembuktian durasi `1800`/`43200` detik, sementara screenshot client membuktikan alamat yang diberikan berada di kelompok yang benar.

## Bukti Screenshot

### Screenshot 1 — Tengen: definisi pool short dan long lease

Memuat file konfigurasi DHCP yang mengatur class dan pool pada Network 3.

![Soal 5 - Tengen: definisi pool short dan long lease](assets/soal-5-ss1-tengen-network3-pool-short-long.png)

**Analisis bukti:** Perbedaan batas rentang dan masa sewa merupakan inti persyaratan No. 5.

### Screenshot 2 — Ino: alamat short lease dan DNS

Tampilan IP `10.66.3.10/24`, gateway `10.66.3.1`, serta DNS/search domain.

![Soal 5 - Ino: alamat short lease dan DNS](assets/soal-5-ss2-ino-short-lease-ip-dns.png)

**Analisis bukti:** Alamat Ino termasuk pool short `.3.10–.3.89`.

### Screenshot 3 — Kusakabe: alamat short lease dan DNS

Tampilan IP `10.66.3.11/24`, gateway `10.66.3.1`, serta DNS/search domain.

![Soal 5 - Kusakabe: alamat short lease dan DNS](assets/soal-5-ss3-kusakabe-short-lease-ip-dns.png)

**Analisis bukti:** Kusakabe berada pada pool dan jaringan yang sama dengan Ino namun menggunakan alamat berbeda.

### Screenshot 4 — Miwa: alamat long lease dan DNS

Tampilan IP `10.66.3.100/24` serta gateway dan resolusi DNS yang sesuai.

![Soal 5 - Miwa: alamat long lease dan DNS](assets/soal-5-ss4-miwa-long-lease-ip-dns.png)

**Analisis bukti:** Miwa tergolong long lease; pada sebagian sesi nama jendela/terminal tampak sebagai `mlwa`, tetapi IP dan konfigurasi mengacu ke klien Miwa.

## Kesimpulan

Pemisahan pool DHCP Network 3 menghasilkan IP yang tepat untuk klien short lease dan long lease, serta menyeragamkan gateway, DNS, dan search domain. Masa lease diverifikasi melalui kebijakan server dan dapat dikonfirmasi kembali melalui field lease saat renewal.

---

# 6. DHCP Static Lease untuk Kugisaki

## Soal

> Kugisaki ditetapkan sebagai personel VIP yang harus mempertahankan alamat yang sama setiap kali terhubung. Buat DHCP static lease berdasarkan MAC Address client tersebut dengan fixed address [PREFIX IP].3.99. Pastikan alamat ini berada di luar seluruh pool dinamis, validasi konfigurasi server, lalu renew lease pada client. Buktikan bahwa alamat yang diterima sesuai dengan reservasi.

## Mengapa Fixed Address Dibuat di Luar Pool

| Komponen | Nilai | Fungsi |
| --- | --- | --- |
| Host | `kugisaki` | Client yang menerima reservasi khusus. |
| MAC Address | `02:42:c0:e6:67:00` | Identitas client DHCP. |
| IP reservation | `10.66.3.99` | IP yang dipertahankan pada request berikutnya. |
| Gateway | `10.66.3.1` | Gateway Network 3. |
| Subnet mask | `/24` | Menjaga alamat tetap di `10.66.3.0/24`. |
| DNS | `10.66.1.2`, `10.66.1.3` | Opsi DNS yang sama dengan client lain. |

## Penjelasan Teknis

IP `10.66.3.99` terletak di luar pool short (`.10–.89`) dan long (`.100–.199`). Hal ini sengaja dilakukan agar server DHCP tidak memberikan alamat tersebut kepada client dinamis lain. Pemetaan berbasis MAC membuat Kugisaki memperoleh alamat yang telah ditentukan selama konfigurasi reservation dan identitas MAC tetap sama.

**Static lease** berbeda dari konfigurasi IP statis lokal: alamat tetap diberikan melalui protokol DHCP. Karena itu Kugisaki tetap menerima DHCP options seperti gateway, DNS, subnet mask, dan domain search dari server.

## Command dan Konfigurasi

Di Tengen terdapat blok host berikut pada `/etc/dhcp/dhcpd.conf`:

```conf
host kugisaki {
    hardware ethernet 02:42:c0:e6:67:00;
    fixed-address 10.66.3.99;
}
```

Validasi syntax dilakukan sebelum server menerima lease baru:

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server status
```

Di Kugisaki, renewal dilakukan dengan klien DHCP (gunakan hati-hati karena dapat mengubah IP aktif):

```bash
udhcpc -i eth0 -q -n
hostname
ip -br addr
ip route
cat /etc/resolv.conf
```

## Validasi

Kugisaki harus memperoleh:

```text
IPv4       : 10.66.3.99/24
Gateway    : 10.66.3.1
Broadcast  : 10.66.3.255
DNS 1      : 10.66.1.2
DNS 2      : 10.66.1.3
Search     : k05.com
```

Untuk memastikan reservation tidak bertabrakan dengan pool dinamis, periksa rentang pada Network 3 dan identitas MAC:

```bash
grep -A4 -B1 'host kugisaki' /etc/dhcp/dhcpd.conf
grep -n 'range 10.66.3.' /etc/dhcp/dhcpd.conf
```

## Hasil Pengujian dan Analisis

Bukti sisi server memperlihatkan `hardware ethernet` dan `fixed-address`, sementara bukti sisi client menunjukkan Kugisaki mendapat `10.66.3.99/24` dengan default gateway `10.66.3.1`. Karena `.99` tidak berada pada pool dinamis, alamat VIP tidak diperebutkan oleh anggota pool lain.

## Bukti Screenshot

### Screenshot 1 — Tengen: deklarasi reservation Kugisaki

Bukti bahwa MAC `02:42:c0:e6:67:00` diarahkan pada IP `10.66.3.99`.

![Soal 6 - Tengen: deklarasi reservation Kugisaki](assets/soal-6-ss1-tengen-kugisaki-fixed-address.png)

**Analisis bukti:** Fixed address dicocokkan dengan hardware Ethernet address untuk menghindari alokasi acak.

### Screenshot 2 — Kugisaki: IP tetap, DNS, dan gateway

Hasil verifikasi IP DHCP `10.66.3.99/24`, default gateway, serta konfigurasi DNS.

![Soal 6 - Kugisaki: IP tetap, DNS, dan gateway](assets/soal-6-ss2-kugisaki-fixed-ip-dns-gateway.png)

**Analisis bukti:** Lease yang diperoleh sesuai dengan reservasi, bukan rentang short maupun long lease.

## Kesimpulan

Reservation khusus Kugisaki berhasil disiapkan di luar pool dinamis dan ditunjukkan melalui konsistensi konfigurasi server dengan alamat yang diterima client.

---

# 7. Audit IP Address, Gateway, DNS, dan DHCP Lease

## Soal

> Setelah aturan alokasi diterapkan, pastikan setiap client menerima konfigurasi jaringan sesuai wilayahnya: subnet mask 255.255.255.0 (/24), gateway dan broadcast address yang benar, DNS [PREFIX IP].1.2 serta [PREFIX IP].1.3, dan domain-search yang ditentukan. Periksa IP address dan routing seluruh client Divisi A dan Divisi B, kemudian cocokkan lease dengan /var/lib/dhcp/dhcpd.leases pada tengen. Pastikan tidak ada alamat yang bertabrakan atau berada di luar kebijakan pool.

## Mengapa Audit Perlu Dilakukan Setelah Pengaturan Pool

| Komponen audit | Nilai yang diperiksa | Risiko bila salah |
| --- | --- | --- |
| Alamat IP | Sesuai class, pool, atau reservation | Client mendapat alamat kelas lain atau terjadi konflik. |
| Prefix subnet | `/24` | Client menganggap host beda subnet sebagai lokal. |
| Default gateway | `.2.1` atau `.3.1` | Trafik keluar segmen gagal diteruskan. |
| Broadcast address | `.2.255` atau `.3.255` | Protokol broadcast tidak sesuai network. |
| DNS DHCP | `10.66.1.2`, `10.66.1.3` | Resolusi nama tidak mengikuti desain. |
| Search domain | `k05.com` | Nama host pendek tidak mendapatkan suffix internal. |
| File lease server | `/var/lib/dhcp/dhcpd.leases` | Perlu membuktikan alokasi tercatat dan menghindari konflik. |
| Tes ping | Gateway dan Tengen | Membedakan konfigurasi lokal dari konektivitas aktual. |

## Analisis Pemetaan dan Kriteria Audit

### Network 2

| Client | Jenis | IP yang terlihat | Gateway |
| --- | --- | --- | --- |
| Itadori | Pool 1 | `10.66.2.10/24` | `10.66.2.1` |
| Fushiguro | Pool 1 | `10.66.2.11/24` | `10.66.2.1` |
| Zenin | Pool 2 | `10.66.2.70/24` | `10.66.2.1` |
| Okkotsu | Pool 2 | `10.66.2.71/24` | `10.66.2.1` |

### Network 3

| Client | Jenis | IP yang terlihat | Gateway |
| --- | --- | --- | --- |
| Ino | Short lease | `10.66.3.10/24` | `10.66.3.1` |
| Kusakabe | Short lease | `10.66.3.11/24` | `10.66.3.1` |
| Miwa | Long lease | `10.66.3.100/24` | `10.66.3.1` |
| Kugisaki | Fixed address | `10.66.3.99/24` | `10.66.3.1` |

Untuk mencegah kesalahan validasi, alamat tetap pada tabel dibandingkan dengan *jenis kebijakan*. Berbeda dengan fixed address Kugisaki, IP client pool tetap bisa berubah pada pembaruan lease selama tidak keluar dari rentang yang diizinkan.

## Command Audit pada Client

Bentuk command yang digunakan untuk audit informasi host:

```bash
hostname
ip -br addr
ip route
cat /etc/resolv.conf
```

Untuk uji konektivitas:

```bash
# Ganti gateway sesuai network client
ping -c 3 10.66.2.1
ping -c 3 10.66.4.10
```

Client Network 3 memakai `10.66.3.1` sebagai gateway. Script audit yang berjalan dalam praktik juga menampilkan status kesesuaian kebijakan dan ringkasan hasil ping.

## Audit Lease pada Tengen

```bash
service isc-dhcp-server status
dhcpd -t -cf /etc/dhcp/dhcpd.conf
cat /var/lib/dhcp/dhcpd.leases
```

`dhcpd.leases` dapat menampung riwayat lease untuk alamat yang sama. Untuk menilai status terbaru, perhatikan blok yang paling akhir untuk IP tersebut, state binding, dan MAC/client identifier. Banyaknya blok dalam file bukan berarti seluruhnya sedang aktif bersamaan.

## Hasil Pengujian dan Analisis

Bukti audit memperlihatkan indikator “HASIL: CLIENT SESUAI KEBIJAKAN” pada beberapa kelas, antara lain Pool 1 (Itadori), Pool 2 (Zenin), short lease (Ino), dan long lease (Miwa). Pada server, file lease dapat dibaca beserta catatan MAC dan status binding. Screenshot No. 4–6 melengkapi audit untuk anggota kelas lain dan Kugisaki. Dengan demikian kebijakan yang disyaratkan terbukti dari dua sudut: konfigurasi alamat pada client dan pencatatan alokasi oleh DHCP Server.

## Bukti Screenshot

### Screenshot 1 — Itadori: audit client Pool 1

Tampilan pemeriksaan IP, subnet, gateway, DNS, dan konektivitas Itadori.

![Soal 7 - Itadori: audit client Pool 1](assets/soal-7-ss1-itadori-audit-pool1.png)

**Analisis bukti:** Status audit menunjukkan klien sesuai kebijakan Pool 1 dan dapat menjangkau tujuan tes.

### Screenshot 2 — Zenin: audit client Pool 2

Memperlihatkan pemeriksaan IP Zenin, resolusi DNS DHCP, dan tes konektivitas.

![Soal 7 - Zenin: audit client Pool 2](assets/soal-7-ss2-zenin-audit-pool2.png)

**Analisis bukti:** Zenin merupakan sampel kelas Pool 2; alamat yang terlihat tidak melanggar rentang pool.

### Screenshot 3 — Ino: audit client short lease

Tampilan audit Ino yang berada dalam rentang short lease Network 3.

![Soal 7 - Ino: audit client short lease](assets/soal-7-ss3-ino-audit-short-lease.png)

**Analisis bukti:** Pemeriksaan gateway, DNS, dan konektivitas membantu membuktikan konfigurasi bukan sekadar keberhasilan memperoleh IP.

### Screenshot 4 — Miwa: audit client long lease

Memperlihatkan konfigurasi Miwa yang termasuk pool long lease.

![Soal 7 - Miwa: audit client long lease](assets/soal-7-ss4-miwa-audit-long-lease.png)

**Analisis bukti:** IP Miwa sesuai rentang `.3.100–.3.199`, sedangkan bukti server menjadi referensi durasi lease.

### Screenshot 5 — Tengen: catatan DHCP lease bagian pertama

Tampilan status DHCP Server dan awal isi `/var/lib/dhcp/dhcpd.leases`.

![Soal 7 - Tengen: catatan DHCP lease bagian pertama](assets/soal-7-ss5-tengen-dhcp-lease-records-1.png)

**Analisis bukti:** Catatan ini menunjukkan hubungan alokasi client dengan basis data lease yang dikelola DHCP Server.

### Screenshot 6 — Tengen: catatan DHCP lease dan Kugisaki

Tampilan lanjutan file lease server, termasuk catatan terkait client dan reservation.

![Soal 7 - Tengen: catatan DHCP lease dan Kugisaki](assets/soal-7-ss6-tengen-dhcp-lease-records-2-kugisaki.png)

**Analisis bukti:** Pemeriksaan file lease melengkapi audit agar tidak hanya berdasarkan output sisi client.

## Kesimpulan

Audit menunjukkan pengalamatan, gateway, DNS, search domain, dan konektivitas sejumlah client sesuai rancangan. Catatan lease di Tengen juga tersedia untuk membantu mengevaluasi pembagian alamat dan potensi konflik. Bukti IP client lainnya turut tersedia pada No. 4–6.

---

# 8. Packet Capture dan Analisis Proses DHCP DORA

## Soal

> Sebelum Curtain dibuka kembali, buktikan bahwa proses pemberian alamat berjalan sesuai protokol. Lakukan packet capture saat salah satu client Network 2 atau Network 3 meminta lease baru. Gunakan tcpdump pada tengen atau jalur menuju Data Center untuk menunjukkan urutan DHCPDISCOVER → DHCPOFFER → DHCPREQUEST → DHCPACK. Identifikasi alamat server, alamat yang diberikan, lease time, dan field giaddr. Pastikan nilai giaddr sesuai dengan interface jichi yang menerima request dari subnet client.

## Mengapa Packet Capture DHCP Diperlukan

Pengujian IP pada client hanya membuktikan konfigurasi **akhir**. Soal ini meminta pembuktian **proses**. Dengan `tcpdump`, paket DHCP di jalur server direkam sehingga seluruh langkah pemberian lease dapat ditelusuri, termasuk identitas server, alamat yang diberikan, durasi, dan nilai `giaddr`.

| Tahap | Arah umum | Kegunaan |
| --- | --- | --- |
| **DHCPDISCOVER** | Client → Relay → Server | Client mencari server DHCP. |
| **DHCPOFFER** | Server → Relay → Client | Server menawarkan alamat dan konfigurasi. |
| **DHCPREQUEST** | Client → Relay → Server | Client meminta tawaran yang dipilih. |
| **DHCPACK** | Server → Relay → Client | Server mengonfirmasi pemberian lease. |

## Analisis Parameter DHCP

Pengujian menggunakan Itadori sebagai client Network 2. Field yang diharapkan dan teramati:

| Parameter | Nilai | Interpretasi |
| --- | --- | --- |
| Server DHCP | `10.66.4.10` | Tengen di Network 4. |
| Alamat client | `10.66.2.10` | IP di Pool 1 Network 2. |
| Lease time | `3600` detik | Jangka waktu lease pada pengujian DORA Itadori. |
| `giaddr` | `10.66.2.1` | Interface relay Jichi tempat request berasal. |
| Prefix client | `/24` | Client berada pada `10.66.2.0/24`. |
| Gateway client | `10.66.2.1` | Jalur keluar Network 2. |

Field `giaddr` **bukan** alamat Tengen dan bukan pula IP client. Nilai tersebut diisi oleh relay untuk menunjukkan segmen asal sehingga server dapat memilih konfigurasi scope yang benar. Karena paket berasal dari Network 2, `giaddr` bernilai `10.66.2.1`.

## Command yang Dijalankan

### A. Capture pada Tengen

Di Tengen digunakan `tcpdump` untuk merekam paket DHCP UDP 67/68 pada interface layanan:

```bash
# Perintah perekaman — jalankan ketika client akan melakukan renewal
# Hentikan capture setelah empat tahap DHCP terkumpul.
tcpdump -i eth0 -s 0 -nn -w /root/soal8-dhcp.pcap 'udp port 67 or udp port 68'
```

### B. Memicu request lease pada Itadori

```bash
# Di Itadori: perbarui request DHCP untuk menghasilkan trafik capture
udhcpc -i eth0 -q -n
ip -br addr
ip route
```

Jika client sudah memiliki lease, capture dapat dilakukan bersamaan dengan pembaruan penuh lease untuk memastikan Discover, Offer, Request, dan ACK tampil. Pengosongan IP aktif sebaiknya dilakukan hanya pada pengujian yang terkendali.

### C. Membaca paket hasil capture

```bash
# Di Tengen
tcpdump -nn -vvv -r /root/soal8-dhcp.pcap   | grep 'DHCP-Message (53)'
```

Untuk mencari metadata server, alamat, lease, dan relay:

```bash
tcpdump -nn -vvv -r /root/soal8-dhcp.pcap   | grep -E 'Gateway-IP|Your-IP|Server-ID|Lease-Time'
```

## Hasil Pengujian dan Analisis

Capture berhasil memperlihatkan keempat jenis pesan DHCP secara lengkap dan berurutan. Paket menunjukkan server `10.66.4.10`, alamat yang diberikan `10.66.2.10`, lease `3600` detik, serta `giaddr = 10.66.2.1`. Sementara itu, Itadori memperoleh alamat Pool 1 yang sama dan gateway `10.66.2.1`. Kecocokan sisi server, relay, dan client menjadi bukti end-to-end pemberian lease.

## Bukti Screenshot

### Screenshot 1 — Tengen: urutan DHCP Discover, Offer, Request, ACK

Output `tcpdump` yang menampilkan keempat pesan inti proses DORA.

![Soal 8 - Tengen: urutan DHCP Discover, Offer, Request, ACK](assets/soal-8-ss1-tengen-pcap-dhcp-dora.png)

**Analisis bukti:** Empat tahap membuktikan proses lease berjalan hingga dikonfirmasi, bukan berhenti di paket penawaran.

### Screenshot 2 — Tengen: Server-ID, alamat lease, dan giaddr

Memperlihatkan field DHCP yang digunakan untuk mengidentifikasi server, IP client, durasi, dan interface relay.

![Soal 8 - Tengen: Server-ID, alamat lease, dan giaddr](assets/soal-8-ss2-tengen-pcap-server-lease-giaddr.png)

**Analisis bukti:** `giaddr = 10.66.2.1` sesuai sisi Network 2 Jichi yang menerima broadcast dari Itadori.

### Screenshot 3 — Itadori: renew lease dan pengalamatan hasil

Menunjukkan request DHCP dari Itadori dan kondisi alamat/gateway setelah memperoleh lease.

![Soal 8 - Itadori: renew lease dan pengalamatan hasil](assets/soal-8-ss3-itadori-dhcp-renew-ip-gateway.png)

**Analisis bukti:** Alamat `10.66.2.10/24` cocok dengan penawaran yang tercatat di capture.

## Kesimpulan

Proses DHCP berlangsung lengkap melalui urutan DORA, dan field teknis pada paket sesuai rute Network 2 melalui Jichi ke Tengen. Dengan demikian relay tidak hanya memberi hasil IP yang benar, tetapi juga bekerja sesuai mekanisme protokol DHCP.

---

# 9. Simulasi Gangguan serta Pemulihan DHCP Relay

## Soal

> Sebuah gangguan memutus jalur relay dan membuat permintaan alamat tidak sampai ke Data Center. Hentikan service DHCP Relay pada jichi, lalu paksa salah satu client di Network 2 atau Network 3 meminta lease baru dan catat gejalanya. Pulihkan service relay, ulangi permintaan DHCP, lalu buktikan bahwa client kembali memperoleh alamat dari pool yang benar dengan gateway semula.

## Mengapa Gangguan Relay Harus Disimulasikan

Soal tidak hanya menguji keberhasilan DHCP saat kondisi normal, tetapi juga memastikan kegagalan ketika satu komponen penting berhenti dan keberhasilan setelah dipulihkan. Relay adalah titik penghubung broadcast client ke server remote. Ketika relay berhenti, client Network 2/3 yang meminta lease baru tidak dapat memperoleh tawaran DHCP dari Tengen meskipun server masih aktif di Network 4.

| Kondisi | Relay Jichi | Request Itadori | Hasil yang diharapkan |
| --- | --- | --- | --- |
| Sebelum gangguan | RUNNING | Diteruskan ke Tengen | Lease berhasil. |
| Simulasi gangguan | STOPPED | Tidak diteruskan | Request baru gagal / timeout. |
| Setelah pemulihan | RUNNING | Diteruskan lagi | Lease Pool 1 berhasil, gateway sama. |

## Perintah yang Dijalankan

Pengujian menggunakan script terpisah agar urutan *stop → fail → start → recover* dapat diulang. Script pada Jichi dan Itadori disimpan dalam direktori `/root` pada node masing-masing.

### A. Menghentikan relay pada Jichi

```bash
# RUN DI JICHI
/root/soal9-jichi.sh stop
/root/soal9-jichi.sh status
```

Perintah ini menghentikan `isc-dhcp-relay`/`dhcrelay` dan memeriksa agar tidak ada proses relay yang masih aktif.

### B. Menguji kegagalan request pada Itadori

```bash
# RUN DI ITADORI
/root/soal9-itadori.sh fail
```

Script uji mengosongkan alamat IPv4 aktif untuk mensimulasikan permintaan lease baru, kemudian memanggil `udhcpc`. Tanpa relay, request DHCP tidak mencapai server lintas-subnet.

### C. Memulihkan layanan relay pada Jichi

```bash
# RUN DI JICHI
/root/soal9-jichi.sh start
/root/soal9-jichi.sh status
```

### D. Mengulang DHCP pada Itadori

```bash
# RUN DI ITADORI
/root/soal9-itadori.sh recover
```

## Validasi

Pada tahap gagal, status Jichi harus `STOPPED`, Itadori mengirim DHCP Discover tanpa mendapatkan lease baru, dan IPv4 pada interface uji tidak terpasang. Setelah restart relay, daemon harus `RUNNING`, tujuan server adalah `10.66.4.10`, dan Itadori kembali mendapat alamat dari Pool 1 (`10.66.2.10–.35`) serta gateway `10.66.2.1`.

**Perbedaan penting:** client yang masih memegang lease lama dapat tetap berkomunikasi untuk sementara meskipun relay mati. Oleh sebab itu pengujian memaksa lease baru, bukan sekadar melakukan `ping` dari client dengan alamat yang sudah aktif.

## Hasil Pengujian dan Analisis

Screenshot menunjukkan status `STOPPED`, kemudian Itadori gagal memperoleh alamat setelah beberapa pengiriman `DHCPDISCOVER` dan menampilkan pesan kegagalan lease. Setelah Jichi mengaktifkan kembali relay, proses `dhcrelay` berjalan dan Itadori memperoleh `10.66.2.10/24` dengan default gateway `10.66.2.1`. Bukti ini memperlihatkan ketergantungan layanan DHCP pada relay serta keberhasilan prosedur pemulihannya.

## Bukti Screenshot

### Screenshot 1 — Jichi: DHCP Relay dihentikan

Bukti penghentian layanan dengan status relay `STOPPED`.

![Soal 9 - Jichi: DHCP Relay dihentikan](assets/soal-9-ss1-jichi-relay-stopped.png)

**Analisis bukti:** Tidak ditemukannya proses relay aktif merupakan dasar bahwa pengujian gangguan memang berlangsung pada komponen yang relevan.

### Screenshot 2 — Itadori: DHCP gagal ketika relay mati

Menampilkan beberapa `DHCPDISCOVER`, kegagalan memperoleh lease, dan pemeriksaan IP setelah pengujian.

![Soal 9 - Itadori: DHCP gagal ketika relay mati](assets/soal-9-ss2-itadori-dhcp-fail-relay-down.png)

**Analisis bukti:** Kegagalan saat relay dimatikan mendukung bahwa request broadcast tidak dapat mencapai Tengen secara langsung.

### Screenshot 3 — Jichi: relay dipulihkan dan berjalan

Menunjukkan status `RUNNING` serta proses `dhcrelay` yang meneruskan ke `10.66.4.10`.

![Soal 9 - Jichi: relay dipulihkan dan berjalan](assets/soal-9-ss3-jichi-relay-recovery-running.png)

**Analisis bukti:** Layanan kembali siap menerima request Network 2 dan Network 3.

### Screenshot 4 — Itadori: DHCP kembali berhasil

Menampilkan penerimaan lease `10.66.2.10` dan kembalinya rute default `10.66.2.1`.

![Soal 9 - Itadori: DHCP kembali berhasil](assets/soal-9-ss4-itadori-dhcp-recover-success.png)

**Analisis bukti:** Pemulihan berhasil tanpa mengubah kebijakan pool dan gateway semula.

## Kesimpulan

Simulasi gangguan membuktikan bahwa DHCP Relay diperlukan untuk pengalokasian alamat client lintas-subnet. Ketika relay dihentikan, request baru gagal; setelah relay dipulihkan, IP Pool 1 dan gateway semula kembali diterima dengan benar.

---

# 10. Autostart DHCP Server dan DHCP Relay Setelah Restart

## Soal

> Setelah gangguan Shibuya tertangani, pastikan pemulihan bertahan setelah restart. Aktifkan autostart DHCP Server pada tengen dan DHCP Relay pada jichi, lalu restart kedua node. Verifikasi status layanan, IP, gateway, lease, dan konektivitas client Network 2–3. Pastikan kebijakan Pool 1, Pool 2, short lease, long lease, dan fixed address tetap berlaku.

## Mengapa Autostart Perlu Dikonfigurasi

Perbaikan layanan saat node masih hidup belum cukup memenuhi ketentuan praktikum. Dalam lingkungan GNS3 berbasis Docker, proses daemon yang dimulai secara manual dapat berhenti setelah node dimatikan atau restart. Karena itu DHCP Server dan DHCP Relay perlu ditautkan ke mekanisme startup node dan diverifikasi ulang setelah **Stop/Start node GNS3**, tanpa menyalakan service secara manual sesudah boot.

| Komponen | Lokasi | Fungsi |
| --- | --- | --- |
| DHCP Relay | `jichi` | Meneruskan DHCP dari Network 2/3 menuju Tengen. |
| DHCP Server | `tengen` | Menjaga ketersediaan daemon `dhcpd`. |
| Startup hook | `/root/init.sh` | Menjalankan script startup otomatis ketika container dimulai, bila dipanggil image. |
| Log startup Jichi | `/root/soal10-jichi-startup.log` | Bukti aktivitas pemulihan relay saat node boot. |
| Log startup Tengen | `/root/soal10-tengen-startup.log` | Bukti aktivitas pemulihan server saat node boot. |
| File lease | `/var/lib/dhcp/dhcpd.leases` | Menyimpan catatan lease agar state DHCP tetap dapat ditelusuri. |

## Analisis Mekanisme Startup

Image DebiNet pada GNS3 memakai proses inisialisasi berbasis `/etc/debinet-init.sh`; hook lokal `/root/init.sh` dapat dimanfaatkan untuk memanggil konfigurasi startup jika executable dan benar-benar di-load image tersebut. Pada node Jichi, startup menunggu tersedianya IP pada `eth4` (`10.66.4.1/24`), mengaktifkan forwarding IPv4, dan memastikan `dhcrelay` berjalan. Pada node Tengen, startup menunggu `eth0` (`10.66.4.10/24`), memvalidasi `dhcpd.conf`, dan menyalakan `dhcpd` apabila belum aktif.

Pemeriksaan menunggu IP ini diperlukan untuk menghindari *race condition*: service dijalankan ketika interface belum siap atau route belum tersedia. Pemeriksaan menggunakan `pgrep` membantu mencegah duplikasi daemon ketika hook terpanggil lebih dari sekali.

## Command yang Dijalankan

### A. Startup relay pada Jichi

Prinsip perintah pemeriksaan:

```bash
# Di Jichi
ip -4 addr show dev eth4
sysctl -w net.ipv4.ip_forward=1
pgrep -a dhcrelay
service isc-dhcp-relay status
```

Script startup praktikum disiapkan pada `/root/soal10-jichi-startup.sh`, sementara catatan eksekusinya ada di `/root/soal10-jichi-startup.log`. Isi `init.sh` memanggil script startup tersebut pada saat boot. Ketersediaan hook harus disesuaikan dengan image yang digunakan.

### B. Startup server pada Tengen

```bash
# Di Tengen
ip -4 addr show dev eth0
dhcpd -t -cf /etc/dhcp/dhcpd.conf
pgrep -a dhcpd
service isc-dhcp-server status
```

Script startup di Tengen menggunakan `/root/soal10-tengen-startup.sh` dan menghasilkan `/root/soal10-tengen-startup.log`.

### C. Memverifikasi autostart setelah restart node

**Pengujian dilakukan dengan menghentikan dan menjalankan kembali node Jichi serta Tengen dari GNS3.** Setelah keduanya aktif, periksa kondisi layanan **sebelum** menjalankan perintah `start` manual:

```bash
# Jichi
cat /root/soal10-jichi-startup.log
pgrep -a dhcrelay
cat /proc/sys/net/ipv4/ip_forward
```

```bash
# Tengen
cat /root/soal10-tengen-startup.log
pgrep -a dhcpd
service isc-dhcp-server status
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

### D. Audit ulang client

Setelah kedua daemon tersedia, client dapat diperiksa dengan:

```bash
hostname
ip -br addr
ip route
cat /etc/resolv.conf
```

Bila perlu, lakukan request baru menggunakan `udhcpc` untuk memastikan server dan relay dapat memproses lease setelah restart.

## Hasil dan Analisis Autostart

Dari screenshot yang tersedia, Jichi kembali menampilkan relay `RUNNING` dan IP forwarding `1` setelah node dijalankan. Tengen menunjukkan proses DHCP Server aktif beserta hasil pemeriksaan syntax. Client Itadori kembali sesuai Pool 1, Ino sesuai kelompok short lease, dan Kugisaki tetap menggunakan fixed address `10.66.3.99`. Bukti tersebut menguatkan bahwa kombinasi service dan kebijakan DHCP tetap berlaku setelah pemulihan node.

Namun, screenshot pengujian ulang **tidak mencakup seluruh delapan client** secara bersamaan: sampel setelah restart yang secara khusus didokumentasikan adalah Itadori, Ino, dan Kugisaki. Pemeriksaan Pool 2 dan Miwa telah tersedia di Soal 4–7 sebelum restart. Untuk pembuktian menyeluruh jika diminta asisten, audit kembali Fushiguro, Zenin, Okkotsu, Kusakabe, dan Miwa setelah restart dan tambahkan screenshot barunya.

## Bukti Screenshot

### Screenshot 1 — Jichi: DHCP Relay autostart setelah restart

Bukti pemeriksaan log startup Jichi, forwarding, dan proses relay yang hidup setelah node dimulai ulang.

![Soal 10 - Jichi: DHCP Relay autostart setelah restart](assets/soal-10-ss1-jichi-autostart-relay-after-restart.png)

**Analisis bukti:** Keberadaan daemon pascarestart membedakan autostart dari prosedur pemulihan manual pada Soal 9.

### Screenshot 2 — Tengen: DHCP Server autostart setelah restart

Bukti status `dhcpd` dan validasi konfigurasi setelah restart Tengen.

![Soal 10 - Tengen: DHCP Server autostart setelah restart](assets/soal-10-ss2-tengen-autostart-server-after-restart.png)

**Analisis bukti:** Layanan server perlu menyala secara mandiri sebelum client dapat menerima IP melalui Jichi.

### Screenshot 3 — Itadori: Pool 1 masih sesuai setelah restart

Bukti audit IP/gateway/DNS Itadori setelah node infrastruktur direstart.

![Soal 10 - Itadori: Pool 1 masih sesuai setelah restart](assets/soal-10-ss3-itadori-pool1-audit-after-restart.png)

**Analisis bukti:** Alokasi Network 2 tetap tersedia dan sesuai Pool 1.

### Screenshot 4 — Ino: kelompok short lease masih sesuai

Bukti audit Ino setelah restart yang memperlihatkan konfigurasi short lease.

![Soal 10 - Ino: kelompok short lease masih sesuai](assets/soal-10-ss4-ino-short-lease-audit-after-restart.png)

**Analisis bukti:** Pengelompokan Network 3 tidak hilang hanya karena daemon dihidupkan kembali.

### Screenshot 5 — Kugisaki: fixed address tetap berlaku

Bukti audit ulang Kugisaki pada `10.66.3.99/24`.

![Soal 10 - Kugisaki: fixed address tetap berlaku](assets/soal-10-ss5-kugisaki-fixed-ip-audit-after-restart.png)

**Analisis bukti:** Reservation untuk MAC khusus tetap diterapkan sesudah proses restart.

## Kesimpulan

Bukti layanan dan sebagian audit client setelah restart mendukung bahwa DHCP Relay di Jichi serta DHCP Server di Tengen berhasil dijalankan kembali secara otomatis dan kebijakan inti DHCP tidak berubah. Pengujian tambahan pada seluruh client tetap dapat dilengkapi untuk bukti autostart yang lebih komprehensif.

---

## Penutup Sementara

Sampai tahap No. 10, praktikum telah membentuk jalur routing dasar, DHCP Server, DHCP Relay, kebijakan pembagian IP, mekanisme verifikasi lease, pengujian paket DORA, serta prosedur pemulihan ketika relay terganggu. Screenshot yang disertakan mendokumentasikan tiap tahapan berdasarkan hasil praktik. Soal 11 dan seterusnya akan ditambahkan di bagian bawah README setelah konfigurasi dan pengujian berikutnya selesai.

**Catatan pelaporan:** untuk menyamakan file script laporan dengan konfigurasi yang benar-benar diterapkan, arsipkan `.sh` asli dari `/root` masing-masing node ke folder `scripts/` secara terpisah. Script hasil rekonstruksi atau contoh pada laporan tidak boleh dianggap sebagai pengganti otomatis file asli.
