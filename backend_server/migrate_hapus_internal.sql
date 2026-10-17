-- ============================================================================
-- MIGRASI: Hapus kata "internal" dari nama tabel & kolom
--
-- Khusus database yang SUDAH ADA dan masih memakai nama lama.
-- Untuk instalasi baru tidak perlu dijalankan — db_absen_tjs.sql sudah nama baru.
--
-- Jalankan SEKALI (tidak idempotent):
--     mariadb -u tjs_app -ptjs_app_2026 db_absen_tjs < backend_server/migrate_hapus_internal.sql
--
-- Proses: rename tabel -> drop FK -> rename kolom -> buat ulang FK.
-- Data tidak dihapus/diubah.
-- ============================================================================

USE `db_absen_tjs`;

SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------------
-- 1) Rename tabel (hapus sufiks _internal)
-- ---------------------------------------------------------------------------
RENAME TABLE
  `tb_karyawan_internal`  TO `tb_karyawan`,
  `tb_site_internal`      TO `tb_site`,
  `tb_absen_internal`     TO `tb_absen`,
  `tb_pengajuan_internal` TO `tb_pengajuan`,
  `tb_pinjaman_internal`  TO `tb_pinjaman`,
  `tb_slip_gaji_internal` TO `tb_slip_gaji`;

-- ---------------------------------------------------------------------------
-- 2) Lepas foreign key yang menunjuk/memakai kolom yang akan di-rename
--    (fk_log_lokasi tidak perlu dilepas — kolomnya id_site, tidak di-rename)
-- ---------------------------------------------------------------------------
ALTER TABLE `tb_absen`      DROP FOREIGN KEY `fk_log_karyawan`;
ALTER TABLE `tb_pengajuan`  DROP FOREIGN KEY `fk_pengajuan_karyawan`;
ALTER TABLE `tb_pinjaman`   DROP FOREIGN KEY `fk_pinjaman_karyawan`;
ALTER TABLE `tb_slip_gaji`  DROP FOREIGN KEY `fk_slip_karyawan`;
ALTER TABLE `tb_notifikasi` DROP FOREIGN KEY `fk_notifikasi_karyawan`;

-- ---------------------------------------------------------------------------
-- 3) Rename kolom
-- ---------------------------------------------------------------------------
ALTER TABLE `tb_karyawan`
  CHANGE COLUMN `id_karyawan_internal`  `id_karyawan`  INT(11) NOT NULL AUTO_INCREMENT,
  CHANGE COLUMN `nik_karyawan_internal` `nik_karyawan` VARCHAR(50) NOT NULL;

ALTER TABLE `tb_pengajuan`
  CHANGE COLUMN `id_karyawan_internal` `id_karyawan` INT(11) NOT NULL;

ALTER TABLE `tb_pinjaman`
  CHANGE COLUMN `id_karyawan_internal` `id_karyawan` INT(11) NOT NULL;

-- Rename unique index nik_karyawan_internal -> nik_karyawan
ALTER TABLE `tb_karyawan` RENAME INDEX `nik_karyawan_internal` TO `nik_karyawan`;

-- ---------------------------------------------------------------------------
-- 4) Buat ulang foreign key dengan kolom baru
-- ---------------------------------------------------------------------------
ALTER TABLE `tb_absen` ADD CONSTRAINT `fk_log_karyawan`
  FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `tb_pengajuan` ADD CONSTRAINT `fk_pengajuan_karyawan`
  FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `tb_pinjaman` ADD CONSTRAINT `fk_pinjaman_karyawan`
  FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `tb_slip_gaji` ADD CONSTRAINT `fk_slip_karyawan`
  FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `tb_notifikasi` ADD CONSTRAINT `fk_notifikasi_karyawan`
  FOREIGN KEY (`id_karyawan`) REFERENCES `tb_karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE;

SET FOREIGN_KEY_CHECKS = 1;
