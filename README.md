# HadirKa

Aplikasi absensi karyawan HadirKa (Flutter) + API website HRIS (PHP + MySQL).

## Konfigurasi Aplikasi Flutter (`.env`)

Konfigurasi environment aplikasi ada di file **`.env`** di root project (template: `.env.example`):

| Key | Default | Keterangan |
| --- | --- | --- |
| `API_BASE_URL` | kosong = otomatis per platform (desktop/web: `localhost:8000/api`, Android: `10.174.154.8:8000/api`) | URL server API website IPM HRIS |
| `API_FALLBACK_IPS` | daftar IP lokal | Kandidat URL untuk deteksi otomatis server di jaringan lokal (dipisah koma) |
| `API_TIMEOUT_SECONDS` | `8` | Timeout request API (detik) |
| `UPDATE_VERSION_URL` | kosong = update dimatikan | URL HTTPS `version.json` untuk update APK Android |

Catatan:
- `.env` di-bundle sebagai asset saat build — setelah diubah, jalankan **hot restart (`R`)** atau jalankan ulang aplikasi.
- File `.env` **sengaja ikut ter-commit** (berisi nilai non-rahasia dan wajib ada saat build). Template-nya di `.env.example`.
- URL server juga bisa diganti saat runtime dari dalam aplikasi (tersimpan di SharedPreferences, key `custom_server_url`) tanpa perlu rebuild.
- Update APK self-hosted hanya aktif jika `UPDATE_VERSION_URL` diisi. URL harus HTTPS dan mengembalikan JSON versi terbaru.

## Google Maps Flutter

Peta absensi memakai `google_maps_flutter`. Buat API key pada Google Cloud,
aktifkan **Maps SDK for Android** dan **Maps SDK for iOS**, lalu isi key pada
konfigurasi native. Batasi key berdasarkan package ID, SHA-1 Android, dan
bundle ID iOS.

Android: tambahkan pada `android/local.properties` (file tidak di-commit):

```properties
MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

Untuk iOS, isi `GOOGLE_MAPS_API_KEY` pada Build Settings/Xcode atau pada
`ios/Flutter/Debug.xcconfig` dan `ios/Flutter/Release.xcconfig`, lalu jalankan:

```bash
flutter pub get
cd ios && pod install && cd ..
flutter run
```

Tanpa API key valid, widget map tetap dibuat tetapi tile Google Maps tidak
ditampilkan.

## Setup API Website & Database

```bash
# Dev: jalankan dari root website IPM HRIS
php -S 0.0.0.0:8000 router.php
```

API berasal dari website IPM HRIS pada `http://localhost:8000/api`.
Untuk produksi, gunakan Apache/XAMPP/Laragon dengan `mod_rewrite` aktif.

## Akun Login Demo (untuk testing)

Password akun demo: gunakan kredensial yang disediakan administrator IPM HRIS.

| NIK / ID | Nama | Jabatan |
| --- | --- | --- |
| `IPM-00002` | Ahmad Fauzan | Operator Produksi |
| `IPM-00001` | Budi Santoso | Kepala Teknik |
| `IPM-00003` | Siti Rahmawati | Staf Administrasi |

Akun baru juga bisa didaftarkan langsung dari aplikasi (menu **Daftar Sekarang**) atau lewat halaman kelola user.

## Database

Database dan kredensial dikelola oleh website IPM HRIS. Aplikasi Flutter tidak
terhubung langsung ke database; semua data diakses melalui API website.
