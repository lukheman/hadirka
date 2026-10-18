import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';

class HalamanIzinAwal extends StatefulWidget {
  final Future<void> Function() onSelesai;

  const HalamanIzinAwal({super.key, required this.onSelesai});

  @override
  State<HalamanIzinAwal> createState() => _HalamanIzinAwalState();
}

class _HalamanIzinAwalState extends State<HalamanIzinAwal> {
  bool _memproses = false;
  String _statusLokasi = 'Belum diminta';
  String _statusKamera = 'Belum diminta';
  String _statusNotifikasi = 'Belum diminta';
  String _statusPengingat = 'Belum diminta';

  @override
  void initState() {
    super.initState();
    _muatStatusIzin();
  }

  Future<void> _muatStatusIzin() async {
    final lokasi = await Geolocator.checkPermission();
    final kamera = await Permission.camera.status;
    final notifikasi = await Permission.notification.status;
    final pengingat =
        await NotificationService().canScheduleExactNotifications();
    var statusLokasi = _labelIzin(lokasi);

    if (lokasi == LocationPermission.always ||
        lokasi == LocationPermission.whileInUse) {
      try {
        final akurasi = await Geolocator.getLocationAccuracy();
        statusLokasi = akurasi == LocationAccuracyStatus.reduced
            ? 'Approximate — perlu Precise'
            : 'Precise aktif';
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _statusLokasi = statusLokasi;
      _statusKamera = _labelPermissionStatus(kamera);
      _statusNotifikasi = _labelPermissionStatus(notifikasi);
      _statusPengingat = pengingat == null
          ? 'Tidak diperlukan'
          : pengingat
              ? 'Diizinkan'
              : 'Belum diizinkan';
    });
  }

  Future<void> _mintaSemuaIzin() async {
    if (_memproses) return;
    setState(() => _memproses = true);

    try {
      await _mintaLokasi();
      await Permission.camera.request();
      final notifikasiDiizinkan =
          await NotificationService().requestPermissions();
      if (notifikasiDiizinkan) {
        await NotificationService().scheduleDailyReminders();
      }

      await _muatStatusIzin();
    } finally {
      if (mounted) setState(() => _memproses = false);
    }
  }

  Future<void> _mintaLokasi() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if ((permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) &&
        Platform.isIOS) {
      try {
        await Geolocator.requestTemporaryFullAccuracy(
          purposeKey: 'AbsensiPresisi',
        );
      } catch (_) {}
    }
  }

  Future<void> _bukaPengaturan() async {
    await openAppSettings();
    await _muatStatusIzin();
  }

  String _labelIzin(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Belum diizinkan';
      case LocationPermission.deniedForever:
        return 'Ditolak permanen';
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return 'Diizinkan';
      case LocationPermission.unableToDetermine:
        return 'Belum tersedia';
    }
  }

  String _labelPermissionStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) return 'Diizinkan';
    if (status.isPermanentlyDenied || status.isRestricted) {
      return 'Ditolak permanen';
    }
    return 'Belum diizinkan';
  }

  bool get _perluPengaturan =>
      _statusLokasi.contains('Approximate') ||
      _statusLokasi.contains('permanen') ||
      _statusKamera.contains('permanen') ||
      _statusNotifikasi.contains('permanen') ||
      _statusPengingat.contains('permanen') ||
      _statusPengingat == 'Belum diizinkan';

  bool get _semuaIzinSiap =>
      _statusLokasi == 'Precise aktif' &&
      _statusKamera == 'Diizinkan' &&
      _statusNotifikasi == 'Diizinkan' &&
      (_statusPengingat == 'Diizinkan' ||
          _statusPengingat == 'Tidak diperlukan');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 42, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Siapkan izin aplikasi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aplikasi membutuhkan beberapa izin untuk absensi dan layanan karyawan. Izinkan semuanya agar fitur berjalan normal.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              _buildIzinItem(
                Icons.location_on_outlined,
                'Lokasi presisi',
                'Validasi site dan jarak absensi GPS.',
                _statusLokasi,
              ),
              _buildIzinItem(
                Icons.camera_alt_outlined,
                'Kamera',
                'Mengambil selfie bukti absensi.',
                _statusKamera,
              ),
              _buildIzinItem(
                Icons.notifications_none,
                'Notifikasi',
                'Pengingat jam masuk dan jam pulang.',
                _statusNotifikasi,
              ),
              _buildIzinItem(
                Icons.alarm_outlined,
                'Jadwal pengingat',
                'Menjalankan pengingat presensi tepat waktu.',
                _statusPengingat,
              ),
              const SizedBox(height: 24),
              if (_semuaIzinSiap) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: AppColors.success),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Semua izin wajib sudah aktif.',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _memproses ? null : widget.onSelesai,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Lanjutkan ke Login'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ] else ...[
                FilledButton.icon(
                  onPressed: _memproses ? null : _mintaSemuaIzin,
                  icon: _memproses
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_open_outlined),
                  label: Text(_memproses
                      ? 'Meminta izin...'
                      : 'Izinkan kebutuhan aplikasi'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                if (_perluPengaturan) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _memproses ? null : _bukaPengaturan,
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Buka Pengaturan Aplikasi'),
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'Semua izin wajib diaktifkan sebelum masuk ke aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIzinItem(
    IconData ikon,
    String judul,
    String keterangan,
    String status,
  ) {
    final aktif = status == 'Diizinkan' || status == 'Precise aktif';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(ikon, color: aktif ? AppColors.success : AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(keterangan,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              status,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: aktif ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
