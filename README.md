# TJS Absensi App

Aplikasi absensi karyawan PT Triputra Jaya Sultra (Flutter) + backend API (Node.js/Express + MariaDB/MySQL).

## Konfigurasi Aplikasi Flutter (`.env`)

Konfigurasi environment aplikasi ada di file **`.env`** di root project (template: `.env.example`):

| Key | Default | Keterangan |
| --- | --- | --- |
| `API_BASE_URL` | kosong = otomatis per platform (desktop/web: `localhost:3000`, Android: `10.174.154.8:3000`) | URL server API |
| `API_FALLBACK_IPS` | daftar IP lokal | Kandidat URL untuk deteksi otomatis server di jaringan lokal (dipisah koma) |
| `API_TIMEOUT_SECONDS` | `8` | Timeout request API (detik) |

Catatan:
- `.env` di-bundle sebagai asset saat build — setelah diubah, jalankan **hot restart (`R`)** atau jalankan ulang aplikasi.
- File `.env` **sengaja ikut ter-commit** (berisi nilai non-rahasia dan wajib ada saat build). Template-nya di `.env.example`.
- URL server juga bisa diganti saat runtime dari dalam aplikasi (tersimpan di SharedPreferences, key `custom_server_url`) tanpa perlu rebuild.

## Setup Backend & Database

```bash
# 1. Setup database (sekali saja, butuh akses admin MySQL)
sudo mariadb < backend_server/db_absen_tjs.sql

# 2. Install dependency & jalankan backend
cd backend_server
npm install
npm start
```

Backend berjalan di `http://localhost:3000/api`.

## Akun Login Demo (untuk testing)

Password semua akun di bawah: **`tjs2026`**

| NIK / ID | Nama | Jabatan |
| --- | --- | --- |
| `TJS-2024-089` | Ahmad Fauzan | Operator Produksi |
| `TJS-2024-001` | Budi Santoso | Kepala Teknik |
| `TJS-2024-002` | Siti Rahmawati | Staf Administrasi |

Akun baru juga bisa didaftarkan langsung dari aplikasi (menu **Daftar Sekarang**) atau lewat halaman kelola user.

## Kredensial Database

| Item | Nilai |
| --- | --- |
| Database | `db_absen_tjs` |
| User backend | `tjs_app` |
| Password | `tjs_app_2026` |

Kredensial ini dipakai oleh `backend_server/server.js` dan bisa dioverride dengan environment variable `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT`.
