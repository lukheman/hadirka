/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;
DROP TABLE IF EXISTS `tb_absen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_absen` (
  `id_absen` int(11) NOT NULL AUTO_INCREMENT,
  `id_karyawan` int(11) NOT NULL,
  `id_lokasi` int(11) DEFAULT NULL,
  `tanggal_absen` date NOT NULL,
  `waktu_masuk` varchar(20) NOT NULL,
  `waktu_keluar` varchar(20) DEFAULT NULL,
  `nama_lokasi` varchar(100) NOT NULL,
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  `jarak_meter` double NOT NULL DEFAULT 0,
  `status_kehadiran` varchar(50) NOT NULL,
  `keterlambatan_menit` int(11) NOT NULL DEFAULT 0,
  `is_tepat_waktu` tinyint(1) NOT NULL DEFAULT 1,
  `foto_selfie_path` text DEFAULT NULL,
  `dibuat_pada` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_absen`),
  KEY `fk_log_lokasi` (`id_lokasi`),
  KEY `fk_log_karyawan` (`id_karyawan`),
  CONSTRAINT `fk_log_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_log_lokasi` FOREIGN KEY (`id_lokasi`) REFERENCES `tb_site` (`id_site`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_karyawan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_karyawan` (
  `id_karyawan` int(11) NOT NULL AUTO_INCREMENT,
  `nik_karyawan` varchar(50) NOT NULL,
  `jenis_kelamin` varchar(10) DEFAULT NULL,
  `id_site` int(11) DEFAULT NULL,
  `nama_karyawan` varchar(100) NOT NULL,
  `jabatan` varchar(100) DEFAULT NULL,
  `gaji_pokok` double DEFAULT 0,
  `nama_bank` varchar(50) DEFAULT NULL,
  `no_rek` varchar(50) DEFAULT NULL,
  `atas_nama_rek` varchar(100) DEFAULT NULL,
  `status_karyawan` varchar(50) DEFAULT 'AKTIF',
  `tgl_masuk` date DEFAULT NULL,
  `tgl_keluar` date DEFAULT NULL,
  `ket_keluar` text DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `foto_profil` text DEFAULT NULL,
  `dibuat_pada` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_karyawan`),
  UNIQUE KEY `nik_karyawan` (`nik_karyawan`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_notifikasi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_notifikasi` (
  `id_notifikasi` int(11) NOT NULL AUTO_INCREMENT,
  `id_karyawan` int(11) NOT NULL,
  `judul` varchar(150) NOT NULL,
  `pesan` text NOT NULL,
  `kategori` varchar(50) NOT NULL DEFAULT 'presensi',
  `is_dibaca` tinyint(1) NOT NULL DEFAULT 0,
  `dibuat_pada` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_notifikasi`),
  KEY `fk_notifikasi_karyawan` (`id_karyawan`),
  CONSTRAINT `fk_notifikasi_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_pengajuan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_pengajuan` (
  `id_pengajuan` int(11) NOT NULL AUTO_INCREMENT,
  `id_karyawan` int(11) NOT NULL,
  `jenis_pengajuan` varchar(50) NOT NULL,
  `rentang_tanggal` varchar(100) NOT NULL,
  `alasan_pengajuan` text NOT NULL,
  `status_approval` enum('MENUNGGU','DISETUJUI','DITOLAK','DIBATALKAN') NOT NULL DEFAULT 'MENUNGGU',
  `lampiran_path` text DEFAULT NULL,
  `dibuat_pada` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_pengajuan`),
  KEY `fk_pengajuan_karyawan` (`id_karyawan`),
  CONSTRAINT `fk_pengajuan_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_pinjaman`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_pinjaman` (
  `id_pinjaman` int(11) NOT NULL AUTO_INCREMENT,
  `id_karyawan` int(11) NOT NULL,
  `tgl_pinjaman` date NOT NULL,
  `tgl_bayar_pinjaman` date NOT NULL,
  `nominal_pinjaman` double NOT NULL,
  `ket_pinjaman` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_pinjaman`),
  KEY `fk_pinjaman_karyawan` (`id_karyawan`),
  CONSTRAINT `fk_pinjaman_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_site` (
  `id_site` int(11) NOT NULL AUTO_INCREMENT,
  `kode_lokasi` varchar(50) NOT NULL,
  `nama_site` varchar(100) NOT NULL,
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  `radius_meter` double NOT NULL DEFAULT 80,
  `lokasi` text DEFAULT NULL,
  `deskripsi_lokasi` text DEFAULT NULL,
  `is_aktif` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_site`),
  UNIQUE KEY `kode_lokasi` (`kode_lokasi`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_slip_gaji`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_slip_gaji` (
  `id_slip_gaji` int(11) NOT NULL AUTO_INCREMENT,
  `id_karyawan` int(11) NOT NULL,
  `periode` varchar(50) NOT NULL DEFAULT 'Agustus 2026',
  `gaji_pokok` double NOT NULL DEFAULT 0,
  `tunjangan` double NOT NULL DEFAULT 0,
  `potongan` double NOT NULL DEFAULT 0,
  `total_diterima` double NOT NULL DEFAULT 0,
  `status_rilis` varchar(20) NOT NULL DEFAULT 'DITERBITKAN',
  `catatan` text DEFAULT NULL,
  `dibuat_pada` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_slip_gaji`),
  KEY `fk_slip_karyawan` (`id_karyawan`),
  CONSTRAINT `fk_slip_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

