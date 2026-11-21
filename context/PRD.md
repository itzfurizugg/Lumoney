# PRD — Aplikasi Money Management & Celengan

**Platform:** Flutter (Android & iOS) · **Status:** Draft v1.0 · **Tanggal:** 20 November 2026

---

## 1. Ringkasan

Aplikasi pencatat keuangan pribadi dan celengan digital yang **sepenuhnya berjalan lokal di HP**. Tidak ada akun, tidak ada server milik aplikasi, dan tidak ada data keuangan yang dikirim ke pihak lain. Pengguna bisa mencatat transaksi (termasuk lewat suara), memantau cashflow, mengelola beberapa dompet, dan menabung untuk target tertentu dengan visualisasi progres dan ETA. Fitur AI bersifat opsional dan memakai **token/API key pribadi milik pengguna sendiri**.

## 2. Latar Belakang & Masalah

- Aplikasi keuangan populer umumnya mewajibkan akun dan menyimpan data di cloud, sehingga muncul kekhawatiran privasi.
- Mencatat pengeluaran secara manual terasa merepotkan, sehingga banyak orang berhenti setelah beberapa hari.
- Menabung untuk target (gadget, liburan, dana darurat) sering tidak punya visual progres yang memotivasi.
- Pengguna yang sudah punya catatan di Excel/CSV sulit pindah ke aplikasi baru.

## 3. Tujuan & Non-Tujuan

### Tujuan

1. Pencatatan transaksi cepat (< 10 detik per transaksi, < 5 detik dengan voice input).
2. Privasi penuh: seluruh data tersimpan di perangkat.
3. Pengalaman menabung yang memotivasi (progres, ETA, kalender kontribusi).
4. Wawasan keuangan yang menarik lewat grafik dan ringkasan AI ala *wrapped*.
5. Data aman lewat backup ke Google Drive milik pengguna sendiri.

### Non-Tujuan (v1)

- Sinkronisasi real-time antar perangkat.
- Integrasi langsung ke rekening bank / e-wallet (open banking).
- Akun pengguna, login, atau backend milik aplikasi.
- Fitur investasi, utang-piutang, atau tagihan berulang (dipertimbangkan v2).
- Kolaborasi/berbagi dompet antar pengguna.

## 4. Target Pengguna

| Persona | Deskripsi | Kebutuhan utama |
|---|---|---|
| Mahasiswa / pekerja muda | Uang bulanan terbatas, ingin tahu ke mana uang pergi | Pencatatan cepat, rekap, celengan target |
| Peduli privasi | Tidak nyaman data keuangan di cloud pihak ketiga | Data lokal, backup di Drive sendiri |
| Pindahan dari Excel | Sudah punya catatan di spreadsheet | Import .xlsx/.csv |
| Penabung bertarget | Menabung untuk barang/liburan tertentu | Progres, ETA, motivasi visual |

## 5. Prinsip Produk

- **Local-first:** sumber kebenaran data adalah database di perangkat.
- **Privasi by default:** tidak ada analitik yang membawa data keuangan; tidak ada pengiriman data tanpa aksi eksplisit pengguna.
- **Opt-in untuk AI:** fitur AI mati sampai pengguna memasukkan token sendiri dan memahami data apa yang dikirim.
- **Cepat & ringan:** semua fitur inti jalan offline.

## 6. Ruang Lingkup Fitur

### 6.1 Fondasi (Lintas Fitur)

| ID | Kebutuhan | Prioritas |
|---|---|---|
| F-01 | Semua data (transaksi, dompet, celengan, gambar) disimpan di penyimpanan lokal perangkat | P0 |
| F-02 | Aplikasi inti berfungsi penuh tanpa internet | P0 |
| F-03 | Tidak ada akun/login; onboarding langsung ke pembuatan dompet pertama | P0 |
| F-04 | Kunci aplikasi opsional (PIN/biometrik) | P1 |
| F-05 | Mata uang default Rupiah (IDR) dengan format ribuan; pengaturan mata uang lain di v2 | P1 |

### 6.2 Money Management

#### a. Dompet (Wallet)

- Dompet bawaan: **Cash** dan **Bank**.
- Pengguna bisa membuat dompet kustom (nama, ikon, warna, saldo awal), mengubah, mengarsipkan, dan menghapus.
- Transfer antar dompet (tercatat sebagai satu transaksi tipe transfer, tidak dihitung sebagai pemasukan/pengeluaran).
- Total saldo = penjumlahan seluruh dompet aktif.

#### b. Pencatatan Transaksi

- Tipe: pemasukan, pengeluaran, transfer.
- Field: nominal, dompet, kategori, tanggal/waktu, catatan, (opsional) lampiran foto struk.
- Kategori bawaan + kategori kustom.
- Edit, hapus, dan pencarian/filter (tanggal, kategori, dompet, nominal).

#### c. Voice Input

- Pengguna menekan tombol mikrofon lalu berkata, misalnya: *"Tadi makan siang tiga puluh lima ribu pakai cash"*.
- Sistem mengubah ucapan menjadi transaksi terstruktur (nominal, kategori, dompet, tanggal) dan menampilkan **layar konfirmasi** sebelum disimpan.
- Dua mode:
  - **Dasar (tanpa AI):** speech-to-text bawaan perangkat + parser berbasis aturan untuk pola umum Bahasa Indonesia.
  - **AI voice input (token pribadi):** teks hasil transkripsi dikirim ke penyedia AI pilihan pengguna untuk diekstrak lebih akurat (multi-transaksi dalam satu ucapan, bahasa informal).
- Pengguna selalu bisa mengoreksi hasil sebelum disimpan.

#### d. Bagan & Diagram Cashflow

- Bar chart pemasukan vs pengeluaran per periode.
- Line chart tren saldo.
- Pie/donut chart komposisi pengeluaran per kategori.
- Filter periode (7 hari, 30 hari, bulan ini, tahun ini, rentang kustom) dan filter dompet.

#### e. Rekap Pemasukan & Pengeluaran

- Rekap **harian, mingguan, bulanan, tahunan**: total masuk, total keluar, selisih (net), dan transaksi terbesar.
- Navigasi periode sebelumnya/berikutnya.
- Perbandingan dengan periode sebelumnya (naik/turun dalam persen).

#### f. Import Data (.xlsx dan .csv)

- Pilih file dari penyimpanan perangkat.
- **Langkah pemetaan kolom:** pengguna memetakan kolom file ke field (tanggal, nominal, tipe, kategori, dompet, catatan).
- Pratinjau 10 baris pertama dan validasi (tanggal tidak valid, nominal kosong) sebelum impor.
- Deteksi duplikat sederhana (tanggal + nominal + catatan sama) dengan opsi lewati/timpa.
- Penyediaan template contoh yang bisa diunduh.
- Proses impor berjalan sepenuhnya lokal.

#### g. AI Monthly Wrapped

- Ringkasan bulanan bergaya kartu *story* yang bisa digeser, terinspirasi Spotify Wrapped.
- Isi contoh: total pengeluaran, kategori teratas, hari paling boros, transaksi terbesar, perbandingan dengan bulan lalu, "kepribadian keuangan" bulan itu, dan satu insight utama.
- Angka dan grafik dihitung **secara lokal**; AI hanya menulis narasi/judul dari data agregat.
- Hanya data agregat (bukan daftar transaksi mentah) yang dikirim ke AI secara default; pengguna bisa melihat pratinjau payload sebelum dikirim.
- Hasil disimpan lokal agar tidak perlu memanggil AI ulang.
- Bisa dibagikan sebagai gambar (opsional, atas aksi pengguna).

#### h. AI Spending Advice

- Saran berbasis pola pengeluaran: kategori yang membengkak, peluang penghematan, anggaran yang disarankan.
- Dipicu manual oleh pengguna (tombol "Minta saran"), bukan otomatis.
- Disertai disclaimer bahwa ini bukan nasihat keuangan profesional.

#### i. AI Bank Data Translator (Penyesuaian Data Bank)

Pengguna membawa data dari aplikasi bank atau e-wallet (misalnya blu by BCA, yang punya data saldo dan portofolio keuangan) ke aplikasi ini, lalu AI menerjemahkannya menjadi data lokal aplikasi. Ini bukan integrasi langsung ke bank: pengguna sendiri yang mengambil datanya, sehingga tetap sejalan dengan Non-Tujuan v1.

- **Sumber input:** tangkapan layar (screenshot) mutasi atau portofolio, file PDF mutasi/e-statement, teks yang disalin dari aplikasi bank, dan file .xlsx/.csv dengan kolom tidak standar. Ketersediaan ekspor data berbeda di tiap bank, jadi screenshot dan salin teks menjadi jalur yang dijamin.
- **Yang diterjemahkan:** transaksi (tanggal, nominal, masuk/keluar, deskripsi) menjadi Transaction; kategori ditebak dari deskripsi merchant; rekening, saldo, dan portofolio (saldo utama, tabungan, dll.) menjadi Wallet baru atau dipetakan ke dompet yang sudah ada; tabungan bertarget milik bank bisa dijadikan celengan.
- **Alur:** pilih sumber, pilih dompet tujuan (atau buat otomatis dari nama rekening), AI mengekstrak data ke format terstruktur, lalu layar pratinjau menampilkan tabel hasil dengan status per baris (baru, duplikat, perlu dicek) yang bisa diedit atau dihapus, dan terakhir pengguna mengonfirmasi sebelum data disimpan lokal.
- **Aturan akurasi:** tidak ada yang tersimpan tanpa konfirmasi; baris dengan keyakinan rendah ditandai; duplikat dideteksi (tanggal + nominal + deskripsi); setelah impor, aplikasi menampilkan selisih antara saldo di aplikasi dan saldo di sumber, lalu menawarkan transaksi penyesuaian.
- **Pemetaan tersimpan:** pola format tiap bank/aplikasi yang sudah pernah diimpor disimpan lokal agar impor berikutnya lebih cepat dan konsisten.
- **Privasi:** konten dikirim ke penyedia AI pilihan pengguna dengan token pribadinya, dengan peringatan khusus bahwa dokumen bisa memuat nama dan nomor rekening. Untuk teks dan CSV, nama dan nomor rekening disensor di perangkat sebelum dikirim; untuk gambar, pengguna diminta memotong atau menutup area sensitif. File asli tidak disimpan setelah impor kecuali pengguna memilih menyimpannya.
- **Kebutuhan teknis:** penyedia AI harus mendukung input gambar/dokumen untuk screenshot dan PDF; jika tidak, hanya teks dan CSV yang tersedia.

### 6.3 Celengan (Savings)

| ID | Kebutuhan | Prioritas |
|---|---|---|
| S-01 | Buat celengan baru dengan nama, **target nominal**, dan **tujuan/target celengan** (deskripsi) | P0 |
| S-02 | Upload gambar target celengan dari galeri/kamera; disimpan lokal di direktori aplikasi | P0 |
| S-03 | Setor dan tarik dana ke/dari celengan (opsional dikaitkan ke dompet sumber) | P0 |
| S-04 | Progres visual: persentase, bar/lingkaran, sisa nominal | P0 |
| S-05 | **ETA terkumpul**: perkiraan tanggal target tercapai | P0 |
| S-06 | **Kalender kontribusi** ala GitHub contributions: grid hari berwarna sesuai intensitas setoran | P1 |
| S-07 | Tenggat target opsional dan saran setoran harian/mingguan agar tepat waktu | P1 |
| S-08 | Status celengan: aktif, tercapai (dengan perayaan), diarsipkan | P1 |

**Logika ETA:**

- Rata-rata setoran dihitung dari riwayat setoran (misalnya 30 hari terakhir atau sejak setoran pertama).
- ETA = tanggal hari ini + (sisa nominal ÷ rata-rata setoran per hari).
- Jika riwayat < 3 setoran, tampilkan "Belum cukup data" atau gunakan tenggat jika ada.
- Jika ada tenggat, tampilkan status "di jalur / terlambat" dengan membandingkan ETA dan tenggat.

**Kalender kontribusi:**

- Grid 7 baris (hari) × ±53 kolom (minggu) untuk satu tahun, dengan 4–5 tingkat warna berdasarkan total setoran per hari.
- Bisa dilihat per celengan atau gabungan semua celengan.
- Ketuk sebuah hari untuk melihat daftar setoran pada hari itu.
- Menampilkan *streak* menabung berturut-turut.

### 6.4 AI dengan Token Pribadi (Bring Your Own Key)

- Semua fitur AI (voice input AI, wrapped, advice, bank data translator) **nonaktif** sampai pengguna memasukkan token sendiri di Pengaturan > AI.
- Token disimpan di **secure storage** perangkat (Keychain/Keystore), tidak pernah masuk ke backup Google Drive dan tidak pernah dicatat di log.
- Pengguna memilih penyedia AI yang didukung (daftar final ditentukan saat implementasi; arsitektur dibuat berbasis adapter agar mudah menambah penyedia).
- Sebelum pemanggilan pertama, tampilkan penjelasan: data apa yang dikirim, ke penyedia mana, dan biaya ditanggung pengguna.
- Penanganan error: token tidak valid, kuota habis, tidak ada internet, dengan pesan jelas dan fitur non-AI tetap berjalan.
- Tombol "Hapus token" dan "Uji koneksi".

### 6.5 Backup & Restore ke Google Drive

- Login Google bersifat **opsional** dan hanya untuk fitur backup.
- Gunakan folder khusus aplikasi di Drive pengguna (scope `drive.appdata` atau `drive.file` agar akses minimal).
- Isi backup: database, gambar celengan, dan pengaturan; **token AI dikecualikan**.
- Backup dienkripsi di sisi klien dengan passphrase pilihan pengguna (P1; jika lupa passphrase, data tidak bisa dipulihkan dan ini harus dijelaskan jelas).
- Backup manual (P0) dan backup otomatis terjadwal harian/mingguan lewat WorkManager (P1).
- Restore: pilih versi backup, tampilkan tanggal dan ukuran, konfirmasi bahwa data lokal akan ditimpa.
- Simpan 5 backup terakhir; yang lebih lama dihapus otomatis.

## 7. Alur Pengguna Utama

1. **Onboarding:** pengantar singkat 3 layar, buat dompet pertama (saldo awal), selesai.
2. **Catat cepat:** beranda, tombol +, isi nominal dan kategori, simpan. Alternatif: tombol mikrofon, ucapkan, konfirmasi, simpan.
3. **Menabung:** tab Celengan, buat celengan baru, upload gambar, atur target, setor, lihat progres dan ETA.
4. **Review bulanan:** akhir bulan muncul notifikasi lokal "Wrapped bulan ini siap", buka kartu story.
5. **Pindahan data:** Pengaturan, Import, pilih file, petakan kolom, pratinjau, impor.
6. **Pengamanan data:** Pengaturan, Backup, login Google, backup sekarang.

## 8. Struktur Navigasi (Usulan)

Bottom navigation dengan 4 tab:

- **Beranda** — total saldo, ringkasan bulan ini, grafik cashflow singkat, transaksi terbaru
- **Transaksi** — daftar, filter, rekap harian/mingguan/bulanan/tahunan
- **Celengan** — daftar celengan, kalender kontribusi
- **Wawasan** — grafik detail, Wrapped, AI advice

Pengaturan (dompet, kategori, import, backup, AI, keamanan) diakses dari ikon di Beranda.

### Arah Desain (Fase Awal)

Selama pengembangan, tampilan memakai Material Design standar ala Android 6 (Marshmallow) tanpa kustomisasi visual; desain final sesuai keinginan pemilik produk menyusul setelah fitur selesai.

- **Tema:** `ThemeData` dengan `useMaterial3: false` dan widget bawaan Flutter: AppBar, FloatingActionButton, BottomNavigationBar, Card, ListTile, dan Dialog.
- **Warna:** satu warna primary dan satu accent, latar terang; tanpa dark mode, font kustom, atau animasi kustom.
- **Grafik, kalender kontribusi, dan Wrapped:** memakai warna tema dan komponen sederhana (kartu biasa) dulu.
- **Pemisahan tema:** warna, tipografi, spasi, dan komponen bersama dipusatkan di satu lapisan tema, sehingga redesain nanti cukup mengganti lapisan itu tanpa menyentuh logika fitur.
- **Di luar lingkup fase awal:** dark mode, ilustrasi, ikon kustom, dan transisi halaman kustom.

## 9. Model Data (Garis Besar)

| Entitas | Field utama |
|---|---|
| Wallet | id, nama, ikon, warna, saldo_awal, is_archived |
| Category | id, nama, tipe (income/expense), ikon, warna |
| Transaction | id, tipe, nominal, wallet_id, to_wallet_id (transfer), category_id, tanggal, catatan, lampiran_path |
| SavingsGoal | id, nama, tujuan, target_nominal, deadline, gambar_path, status, created_at |
| SavingsEntry | id, goal_id, nominal (+ setor / − tarik), tanggal, wallet_id (opsional), catatan |
| WrappedReport | id, periode (YYYY-MM), data_agregat (JSON), narasi_ai, created_at |
| AppSettings | key, value (non-sensitif) |

Catatan: nominal disimpan sebagai **integer** (satuan terkecil) untuk menghindari kesalahan floating point.

## 10. Arsitektur Teknis (Usulan)

| Area | Usulan |
|---|---|
| Framework | Flutter (Dart), arsitektur berlapis (presentation, domain, data) |
| State management | Riverpod atau Bloc |
| Database lokal | SQLite via Drift (query agregat untuk rekap) atau Isar |
| Penyimpanan gambar | Direktori dokumen aplikasi; simpan path relatif di database |
| Grafik | fl_chart |
| Voice | speech_to_text (on-device) + parser aturan; adapter AI opsional |
| Import | package excel untuk .xlsx, csv untuk .csv, diproses di isolate agar UI tidak macet |
| Secure storage | flutter_secure_storage |
| Google Drive | google_sign_in + googleapis (Drive v3), scope minimal |
| Notifikasi | flutter_local_notifications |
| Enkripsi backup | AES-GCM dengan kunci turunan passphrase (PBKDF2/Argon2) |

**Aturan privasi arsitektur:**

- Satu-satunya jaringan keluar: (a) panggilan ke penyedia AI atas inisiatif pengguna dan (b) Google Drive untuk backup.
- Tidak ada SDK analitik/iklan yang membaca data keuangan.
- Pengiriman ke AI melalui satu *gateway* internal yang meminimalkan dan mencatat (secara lokal) data apa yang dikirim.

## 11. Persyaratan Non-Fungsional

| Aspek | Target |
|---|---|
| Performa | Cold start < 2 detik; daftar 10.000 transaksi tetap mulus (pagination/lazy loading) |
| Offline | 100% fitur inti berfungsi tanpa internet |
| Keamanan | Token di secure storage; opsi kunci aplikasi; backup terenkripsi |
| Keandalan | Migrasi database berversi; tidak ada kehilangan data saat update |
| Aksesibilitas | Dukungan ukuran font sistem, kontras memadai, label semantik |
| Lokalisasi | Bahasa Indonesia (utama), Inggris (P2) |
| Ukuran aplikasi | Target < 40 MB |
| Impor | 5.000 baris diproses < 10 detik di perangkat menengah |

## 12. Privasi & Kepatuhan

- Kebijakan privasi sederhana: data tetap di perangkat; jelaskan dua kasus pengecualian (AI dan Google Drive) dan bahwa keduanya opt-in.
- Layar persetujuan sebelum pemakaian AI pertama kali.
- Fitur "Hapus semua data" di Pengaturan.
- Risiko kehilangan data jika HP hilang tanpa backup: ingatkan pengguna secara berkala untuk mencadangkan.
- Perlu memperhatikan kebijakan Google Play dan App Store terkait izin mikrofon, penyimpanan, dan Google Sign-In.

## 13. Metrik Keberhasilan

| Metrik | Target (3 bulan setelah rilis) |
|---|---|
| Retensi D30 | ≥ 25% |
| Rata-rata transaksi tercatat per pengguna aktif per minggu | ≥ 5 |
| Persentase pengguna yang membuat ≥ 1 celengan | ≥ 40% |
| Akurasi voice input (field benar tanpa koreksi) | ≥ 85% mode AI, ≥ 70% mode dasar |
| Pengguna yang mengaktifkan backup Drive | ≥ 30% |
| Crash-free sessions | ≥ 99,5% |

Catatan: karena aplikasi local-first, metrik di atas perlu diukur dengan analitik anonim yang **tidak memuat data keuangan** dan bersifat opt-in, atau lewat survei/rating toko aplikasi.

## 14. Rencana Rilis

| Fase | Isi | Perkiraan |
|---|---|---|
| **MVP (v0.1)** | Dompet, transaksi, kategori, rekap periode, grafik cashflow, celengan lengkap (progres, ETA, gambar), data lokal | 6–8 minggu |
| **v0.2** | Import .xlsx/.csv, kalender kontribusi, voice input dasar, kunci aplikasi | 3–4 minggu |
| **v0.3** | Backup/restore Google Drive, BYO token AI, AI voice input | 3–4 minggu |
| **v1.0** | AI Wrapped, AI Spending Advice, polesan UI, notifikasi lokal, uji beta tertutup | 3–4 minggu |
| **v2 (ide)** | Anggaran per kategori, transaksi berulang, multi-mata uang, widget layar utama, ekspor laporan PDF | — |

## 15. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Data hilang karena HP rusak/hilang | Tinggi | Pengingat backup, backup otomatis, restore yang mudah |
| Biaya/kuota token AI menyulitkan pengguna | Sedang | Fitur AI opsional, kirim data agregat saja, tampilkan estimasi pemakaian |
| Akurasi parsing suara Bahasa Indonesia rendah | Sedang | Layar konfirmasi wajib, mode AI, koreksi cepat |
| Format Excel/CSV bervariasi | Sedang | Pemetaan kolom manual, pratinjau, template contoh |
| Kebocoran token AI | Tinggi | Secure storage, tidak ikut backup, tidak di-log |
| Kebijakan Google Sign-In/Drive berubah | Rendah | Scope minimal, abstraksi layer backup agar bisa ganti penyedia |
| Performa grafik/kalender pada data besar | Sedang | Query agregat di database, caching hasil rekap |

## 16. Pertanyaan Terbuka

1. Penyedia AI mana saja yang didukung di v1 (satu atau beberapa)?
2. Apakah transaksi berulang (gaji, langganan) perlu masuk sebelum v1.0?
3. Apakah celengan boleh dikaitkan ke dompet khusus (saldo celengan dihitung terpisah dari saldo dompet)?
4. Perlu dukungan multi-mata uang sejak awal?
5. Model monetisasi (gratis penuh, donasi, atau fitur premium non-AI)?
6. Apakah perlu ekspor data ke .csv/.xlsx sebagai pasangan fitur import?