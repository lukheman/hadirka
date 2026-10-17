-- ============================================================================
-- SETUP DATABASE ABSENSI TJS (MariaDB / MySQL)
--
-- Jalankan SEKALI sebagai admin database, dari folder ipm-hris-karyawan:
--     sudo mariadb < backend_server/db_absen_tjs.sql
--
-- Script ini bersifat idempotent (aman dijalankan berulang). Yang dibuat:
--   1. Database `db_absen_tjs` + semua tabel
--   2. User database `tjs_app` (dipakai backend_server/server.js)
--   3. Seed lokasi geofence (sesuai koordinat di aplikasi)
--   4. Akun karyawan untuk login aplikasi (password: tjs2026)
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `db_absen_tjs` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_absen_tjs`;

CREATE TABLE IF NOT EXISTS `tb_karyawan` (
  `id_karyawan` INT AUTO_INCREMENT PRIMARY KEY,
  `nik_karyawan` VARCHAR(50) NOT NULL UNIQUE,
  `jenis_kelamin` VARCHAR(10) DEFAULT NULL,
  `id_site` INT DEFAULT NULL,
  `nama_karyawan` VARCHAR(100) NOT NULL,
  `jabatan` VARCHAR(100) DEFAULT NULL,
  `gaji_pokok` DOUBLE DEFAULT 0,
  `nama_bank` VARCHAR(50) DEFAULT NULL,
  `no_rek` VARCHAR(50) DEFAULT NULL,
  `atas_nama_rek` VARCHAR(100) DEFAULT NULL,
  `status_karyawan` VARCHAR(50) DEFAULT 'AKTIF',
  `tgl_masuk` DATE DEFAULT NULL,
  `tgl_keluar` DATE DEFAULT NULL,
  `ket_keluar` TEXT DEFAULT NULL,
  `password` VARCHAR(255) DEFAULT NULL,
  `no_hp` VARCHAR(20) DEFAULT NULL,
  `foto_profil` TEXT DEFAULT NULL,
  `dibuat_pada` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tb_site` (
  `id_site` INT AUTO_INCREMENT PRIMARY KEY,
  `kode_lokasi` VARCHAR(50) NOT NULL UNIQUE,
  `nama_site` VARCHAR(100) NOT NULL,
  `latitude` DOUBLE NOT NULL,
  `longitude` DOUBLE NOT NULL,
  `radius_meter` DOUBLE NOT NULL DEFAULT 80.0,
  `lokasi` TEXT DEFAULT NULL,
  `deskripsi_lokasi` TEXT DEFAULT NULL,
  `is_aktif` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `tb_absen` (
  `id_absen` INT AUTO_INCREMENT PRIMARY KEY,
  `id_karyawan` INT NOT NULL,
  `id_lokasi` INT DEFAULT NULL,
  `tanggal_absen` DATE NOT NULL,
  `waktu_masuk` VARCHAR(20) NOT NULL,
  `waktu_keluar` VARCHAR(20) DEFAULT NULL,
  `nama_lokasi` VARCHAR(100) NOT NULL,
  `latitude` DOUBLE NOT NULL,
  `longitude` DOUBLE NOT NULL,
  `jarak_meter` DOUBLE NOT NULL DEFAULT 0,
  `status_kehadiran` VARCHAR(50) NOT NULL,
  `keterlambatan_menit` INT NOT NULL DEFAULT 0,
  `is_tepat_waktu` TINYINT(1) NOT NULL DEFAULT 1,
  `foto_selfie_path` TEXT DEFAULT NULL,
  `dibuat_pada` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_log_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_log_lokasi` FOREIGN KEY (`id_lokasi`) REFERENCES `tb_site` (`id_site`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tb_pengajuan` (
  `id_pengajuan` INT AUTO_INCREMENT PRIMARY KEY,
  `id_karyawan` INT NOT NULL,
  `jenis_pengajuan` VARCHAR(50) NOT NULL,
  `rentang_tanggal` VARCHAR(100) NOT NULL,
  `alasan_pengajuan` TEXT NOT NULL,
  `status_approval` ENUM('MENUNGGU', 'DISETUJUI', 'DITOLAK', 'DIBATALKAN') NOT NULL DEFAULT 'MENUNGGU',
  `lampiran_path` TEXT DEFAULT NULL,
  `dibuat_pada` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_pengajuan_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tb_pinjaman` (
  `id_pinjaman` INT AUTO_INCREMENT PRIMARY KEY,
  `id_karyawan` INT NOT NULL,
  `tgl_pinjaman` DATE NOT NULL,
  `tgl_bayar_pinjaman` DATE NOT NULL,
  `nominal_pinjaman` DOUBLE NOT NULL,
  `ket_pinjaman` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_pinjaman_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tb_slip_gaji` (
  `id_slip_gaji` INT AUTO_INCREMENT PRIMARY KEY,
  `id_karyawan` INT NOT NULL,
  `periode` VARCHAR(50) NOT NULL DEFAULT 'Agustus 2026',
  `gaji_pokok` DOUBLE NOT NULL DEFAULT 0,
  `tunjangan` DOUBLE NOT NULL DEFAULT 0,
  `potongan` DOUBLE NOT NULL DEFAULT 0,
  `total_diterima` DOUBLE NOT NULL DEFAULT 0,
  `status_rilis` VARCHAR(20) NOT NULL DEFAULT 'DITERBITKAN',
  `catatan` TEXT DEFAULT NULL,
  `dibuat_pada` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_slip_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tb_notifikasi` (
  `id_notifikasi` INT AUTO_INCREMENT PRIMARY KEY,
  `id_karyawan` INT NOT NULL,
  `judul` VARCHAR(150) NOT NULL,
  `pesan` TEXT NOT NULL,
  `kategori` VARCHAR(50) NOT NULL DEFAULT 'presensi',
  `is_dibaca` TINYINT(1) NOT NULL DEFAULT 0,
  `dibuat_pada` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_notifikasi_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================================
-- USER DATABASE UNTUK BACKEND (server.js)
-- Kredensial ini sudah diset sebagai default di backend_server/server.js.
-- Bisa dioverride lewat environment variable DB_USER / DB_PASSWORD.
-- ============================================================================

CREATE USER IF NOT EXISTS 'tjs_app'@'localhost' IDENTIFIED BY 'tjs_app_2026';
CREATE USER IF NOT EXISTS 'tjs_app'@'127.0.0.1' IDENTIFIED BY 'tjs_app_2026';
ALTER USER 'tjs_app'@'localhost' IDENTIFIED BY 'tjs_app_2026';
ALTER USER 'tjs_app'@'127.0.0.1' IDENTIFIED BY 'tjs_app_2026';
GRANT ALL PRIVILEGES ON `db_absen_tjs`.* TO 'tjs_app'@'localhost';
GRANT ALL PRIVILEGES ON `db_absen_tjs`.* TO 'tjs_app'@'127.0.0.1';
FLUSH PRIVILEGES;

USE `db_absen_tjs`;

-- ============================================================================
-- SEED: LOKASI GEOFENCE (koordinat sama dengan lokasi_provider.dart)
-- ============================================================================

INSERT IGNORE INTO `tb_site`
  (`id_site`, `kode_lokasi`, `nama_site`, `latitude`, `longitude`, `radius_meter`, `lokasi`, `deskripsi_lokasi`, `is_aktif`)
VALUES
  (1, 'TJS-KANTOR', 'Kantor TJS Dawi-Dawi', -4.178249, 121.610741, 80, 'Jl. Poros Dawi-Dawi, Kec. Pomalaa, Sulawesi Tenggara', 'Kantor Pusat PT TJS Dawi-Dawi', 1),
  (2, 'TJS-ANTAM', 'Site Antam', -4.168500, 121.601500, 80, 'Kawasan Operasional Tambang Antam Pomalaa', 'Titik Presensi Lapangan Site Antam', 1),
  (3, 'TJS-IPIP', 'Site IPIP', -4.185000, 121.620000, 80, 'Kawasan Industri Park IPIP Pomalaa', 'Titik Presensi Lapangan Site IPIP', 1);

-- ============================================================================
-- SEED: AKUN KARYAWAN UNTUK LOGIN APLIKASI
--
--   NIK / ID        | Nama             | Jabatan            | Password
--   ----------------+------------------+--------------------+-----------
--   TJS-2024-089    | Ahmad Fauzan     | Operator Produksi  | tjs2026
--   TJS-2024-001    | Budi Santoso     | Kepala Teknik      | tjs2026
--   TJS-2024-002    | Siti Rahmawati   | Staf Administrasi  | tjs2026
--
-- Password disimpan sebagai hash bcrypt (bukan teks biasa).
-- Insert memakai INSERT IGNORE: akun yang sudah ada tidak akan ditimpa.
-- ============================================================================

INSERT IGNORE INTO `tb_karyawan`
  (`nik_karyawan`, `nama_karyawan`, `jenis_kelamin`, `id_site`, `jabatan`, `gaji_pokok`, `status_karyawan`, `tgl_masuk`, `password`, `no_hp`, `dibuat_pada`)
VALUES
  ('TJS-2024-089', 'Ahmad Fauzan', 'L', 1, 'Operator Produksi', 4500000, 'AKTIF', '2024-01-15', '$2b$10$ZyinUGoO84Sng4T7z4zOyOuLARaR1KY1BHRNl39JdoXkKQoYHkYWi', '0812-3456-7890', NOW()),
  ('TJS-2024-001', 'Budi Santoso', 'L', 1, 'Kepala Teknik', 9000000, 'AKTIF', '2020-03-01', '$2b$10$SukGo8FYCyduTX0uBe8GsuTWuk9IuI56dNvD.ZfPAezLvjy5wbBm6', '0812-1111-2222', NOW()),
  ('TJS-2024-002', 'Siti Rahmawati', 'P', 1, 'Staf Administrasi', 5000000, 'AKTIF', '2022-07-10', '$2b$10$h/h2H5aUcI8lMIfU7R91CeLDFB1qsTQ3Z9LjOA9mxeozfcbhNBNaC', '0813-3333-4444', NOW());

-- Ringkasan hasil setup
SELECT 'Setup database selesai.' AS status;
SELECT `id_karyawan` AS id, `nik_karyawan` AS nik, `nama_karyawan` AS nama, `jabatan`
FROM `tb_karyawan`
ORDER BY `id_karyawan`;
