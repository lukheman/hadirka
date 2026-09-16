
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `db_absen_tjs` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_absen_tjs`;

CREATE TABLE `tb_karyawan_internal` (
  `id_karyawan_internal` INT AUTO_INCREMENT PRIMARY KEY,
  `nik_karyawan_internal` VARCHAR(50) NOT NULL UNIQUE,
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

CREATE TABLE `tb_site_internal` (
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


CREATE TABLE `tb_absen_internal` (
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
  CONSTRAINT `fk_log_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan_internal` (`id_karyawan_internal`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_log_lokasi` FOREIGN KEY (`id_lokasi`) REFERENCES `tb_site_internal` (`id_site`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_pengajuan_internal` (
  `id_pengajuan` INT AUTO_INCREMENT PRIMARY KEY,
  `id_karyawan_internal` INT NOT NULL,
  `jenis_pengajuan` VARCHAR(50) NOT NULL,
  `rentang_tanggal` VARCHAR(100) NOT NULL,
  `alasan_pengajuan` TEXT NOT NULL,
  `status_approval` ENUM('MENUNGGU', 'DISETUJUI', 'DITOLAK', 'DIBATALKAN') NOT NULL DEFAULT 'MENUNGGU',
  `lampiran_path` TEXT DEFAULT NULL,
  `dibuat_pada` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_pengajuan_karyawan` FOREIGN KEY (`id_karyawan_internal`) REFERENCES `tb_karyawan_internal` (`id_karyawan_internal`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_pinjaman_internal` (
  `id_pinjaman` INT AUTO_INCREMENT PRIMARY KEY,
  `id_karyawan_internal` INT NOT NULL,
  `tgl_pinjaman` DATE NOT NULL,
  `tgl_bayar_pinjaman` DATE NOT NULL,
  `nominal_pinjaman` DOUBLE NOT NULL,
  `ket_pinjaman` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_pinjaman_karyawan` FOREIGN KEY (`id_karyawan_internal`) REFERENCES `tb_karyawan_internal` (`id_karyawan_internal`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_slip_gaji_internal` (
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
  CONSTRAINT `fk_slip_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan_internal` (`id_karyawan_internal`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_notifikasi` (
  `id_notifikasi` INT AUTO_INCREMENT PRIMARY KEY,
  `id_karyawan` INT NOT NULL,
  `judul` VARCHAR(150) NOT NULL,
  `pesan` TEXT NOT NULL,
  `kategori` VARCHAR(50) NOT NULL DEFAULT 'presensi',
  `is_dibaca` TINYINT(1) NOT NULL DEFAULT 0,
  `dibuat_pada` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_notifikasi_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan_internal` (`id_karyawan_internal`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
