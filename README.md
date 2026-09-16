# TJS Absensi App

Aplikasi presensi dan manajemen HR internal untuk karyawan TJS. Proyek ini dibangun dengan kerangka kerja **Flutter** (Mobile/Frontend) dan menggunakan **Node.js + MySQL (XAMPP)** sebagai Backend.

## Fitur Utama
- **Autentikasi (Multi-Role)**: Sistem login untuk Karyawan dan HR Admin.
- **Presensi Geofencing**: Fitur check-in dan check-out dengan validasi radius lokasi dari Backend.
- **Manajemen Ketidakhadiran**: Pengajuan Cuti, Izin, SKS (Surat Keterangan Sakit).
- **Manajemen Pinjaman**: Karyawan dapat mengajukan pinjaman dengan skema tenor ke manajemen HR.
- **Portal HR**: Panel khusus HR untuk mengelola karyawan, menambah lokasi geofence, menyetujui pinjaman, dan melacak presensi.

## Arsitektur Aplikasi

Proyek ini menggunakan pola arsitektur **Feature-First** dikombinasikan dengan **Repository Pattern** untuk memisahkan UI dan Logika Bisnis (Data Layer). 

**Tech Stack**:
- **State Management & DI**: `flutter_riverpod`
- **Networking**: `dio`
- **UI Components**: Native Flutter Widgets dengan pendekatan Material Design custom.

### Struktur Direktori Kunci
```text
lib/
├── core/
│   ├── backend/         # Global provider & inisialisasi backend dependency (Dio, API client)
│   ├── network/         # Konfigurasi `ApiClient` berbasis Dio & definisi exception
│   ├── theme/           # Konfigurasi warna, tipografi, dan tema aplikasi
│   └── utils/           # Fungsi helper (notifikasi UI, converter, dll)
│
└── features/
    ├── attendance/      # Modul Presensi (API Services, Repository, Provider, UI)
    ├── auth/            # Modul Autentikasi (API Services, Repository, Provider, UI)
    ├── dashboard/       # Layar beranda utama untuk Karyawan & HR
    ├── hr/              # Modul Manajemen HR (Approval Cuti, Pengajuan, Geofence, Users)
    └── profile/         # Pengaturan Profil dan Password
```

### Konsep Layering & Keamanan Data
Aplikasi ini sudah **tidak menggunakan** client-side validation untuk memverifikasi waktu atau jarak saat absen. 
Sebaliknya, **Flutter hanya mengirim (push) latitude & longitude mentah (raw data)** ke server, lalu Server Backend NodeJS lah yang memiliki hak prerogatif melakukan kalkulasi Geofence, validasi jam telat/tepat, serta penolakan absen (Anti-Fake GPS/Time Tampering).

## Petunjuk Instalasi & Menjalankan Aplikasi

### 1. Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) terinstall (Pastikan versi sesuai, gunakan `flutter doctor`).
- [XAMPP](https://www.apachefriends.org/index.html) terinstall untuk server database MySQL lokal.
- [Node.js](https://nodejs.org/) terinstall untuk menjalankan backend API.

### 2. Setup Backend & Database (Lokal)
1. Buka XAMPP Control Panel, lalu jalankan module **Apache** dan **MySQL**.
2. Buat database baru di `phpMyAdmin` (misal: `tjs_absen_db`).
3. Import file `.sql` backend (jika ada) ke database tersebut.
4. Buka terminal di folder root backend Node.js.
5. Jalankan `npm install` untuk memasang dependensi backend.
6. Jalankan `npm start` atau `node server.js` (biasanya berjalan di port `3000`).

### 3. Setup Frontend Flutter
1. Buka file konfigurasi API di proyek Flutter ini: `lib/core/network/api_client.dart`.
2. Jika Anda menguji di Emulator Android, ubah `baseUrl` (di dalam file tersebut) menggunakan IP loopback Android `10.0.2.2`:
   ```dart
   final String baseUrl = 'http://10.0.2.2:3000/api';
   ```
3. Jika menggunakan real device yang berada dalam jaringan Wi-Fi yang sama, ubah menjadi IPv4 komputer Anda (misal `192.168.1.10`):
   ```dart
   final String baseUrl = 'http://192.168.1.10:3000/api';
   ```
4. Buka terminal pada root proyek ini, kemudian ambil semua package Flutter:
   ```bash
   flutter pub get
   ```
5. Jalankan proyek Flutter ke Emulator atau device fisik:
   ```bash
   flutter run
   ```

## Catatan Rilis & Pengembangan (Developer Notes)
- `MysqlApiService` monolithic lama telah dirombak penuh (depresiasi & dihapus) dan beralih ke layer service dan repository terpisah.
- Modifikasi UI state selalu diarahkan untuk mengkonsumsi Provider Riverpod daripada memanggil service langsung.
