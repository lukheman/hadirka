import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notification.dart';
import '../providers/absensi_provider.dart';
import 'layar_kamera_selfie.dart';
import 'widgets/foto_selfie_card.dart';
import 'widgets/info_check_in_card.dart';
import 'widgets/jam_absensi_card.dart';
import 'widgets/map_card.dart';
import 'widgets/pesan_error_card.dart';
import 'widgets/pilihan_lokasi_card.dart';
import 'widgets/status_jarak_card.dart';
import 'widgets/tombol_absensi.dart';

class LayarAbsensi extends ConsumerStatefulWidget {
  const LayarAbsensi({super.key});

  @override
  ConsumerState<LayarAbsensi> createState() => _LayarAbsensiState();
}

class _LayarAbsensiState extends ConsumerState<LayarAbsensi> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(absensiProvider.notifier).mulaiPantauLokasi();
    });
  }

  @override
  void dispose() {
    ref.read(absensiProvider.notifier).hentikanPantauLokasi();
    super.dispose();
  }

  Future<void> _prosesAbsensi(String tipe) async {
    final berhasil =
        await ref.read(absensiProvider.notifier).lakukanAbsensi(tipe);

    if (berhasil && mounted) {
      AppNotification.showSuccess(
        context,
        tipe == 'check_in' ? 'Check-in berhasil!' : 'Check-out berhasil!',
      );
    }
  }

  Future<void> _ambilFotoSelfie() async {
    final foto = await Navigator.of(context).push<File>(
      MaterialPageRoute(builder: (_) => const LayarKameraSelfie()),
    );
    if (!mounted || foto == null) return;
    await ref.read(absensiProvider.notifier).simpanFotoSelfie(foto);
  }

  Future<void> _bukaPengaturanLokasi() async {
    final bukaPengaturan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktifkan lokasi presisi'),
        content: const Text(
          'Absensi membutuhkan lokasi presisi agar titik GPS dan jarak ke site dapat divalidasi.\n\n'
          'Pada dialog izin pertama, pilih “Precise”. Jika sebelumnya memilih “Approximate”, aktifkan “Use precise location” di pengaturan aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nanti'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );

    if (!mounted || bukaPengaturan != true) return;
    await openAppSettings();
    if (!mounted) return;
    await ref.read(absensiProvider.notifier).mulaiPantauLokasi();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(absensiProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Absensi Hari Ini',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.primary),
            tooltip: 'Perbarui lokasi GPS',
            onPressed: () {
              ref.read(absensiProvider.notifier).mulaiPantauLokasi();
              AppNotification.showInfo(context, 'Mencari lokasi GPS ulang...');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIntroCard(state),
              const SizedBox(height: 16),
              if (state.pesanError != null) ...[
                PesanErrorCard(
                  pesan: state.pesanError!,
                  onMuatUlangGps: () {
                    ref.read(absensiProvider.notifier).mulaiPantauLokasi();
                  },
                  onBukaPengaturanLokasi: _bukaPengaturanLokasi,
                ),
                const SizedBox(height: 16),
              ],
              if (state.lokasiDipilih == null) ...[
                PilihanLokasiCard(
                  daftarLokasi: state.daftarLokasi,
                  lokasiDipilih: state.lokasiDipilih,
                  onPilihLokasi: (lokasi) {
                    ref.read(absensiProvider.notifier).pilihLokasi(lokasi);
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                _buildSelectedLocation(state),
                const SizedBox(height: 16),
                _buildNextActionCard(state),
                const SizedBox(height: 16),
                if (state.sudahCheckIn && state.dataCheckIn != null) ...[
                  InfoCheckInCard(state: state),
                  const SizedBox(height: 16),
                ],
                JamAbsensiCard(state: state),
                const SizedBox(height: 16),
                MapCard(
                  state: state,
                ),
                const SizedBox(height: 16),
                StatusJarakCard(state: state),
                const SizedBox(height: 16),
                FotoSelfieCard(
                  state: state,
                  onAmbilFoto: () {
                    _ambilFotoSelfie();
                  },
                  onHapusFoto: () {
                    ref.read(absensiProvider.notifier).hapusFoto();
                  },
                ),
                const SizedBox(height: 24),
                TombolAbsensi(
                  state: state,
                  onProsesAbsensi: _prosesAbsensi,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard(AbsensiState state) {
    final sudahSelesai = state.sudahCheckOut;
    final judul = sudahSelesai
        ? 'Absensi hari ini selesai'
        : state.sudahCheckIn
            ? 'Anda sedang bekerja'
            : 'Siap melakukan absensi?';
    final deskripsi = sudahSelesai
        ? 'Semua catatan kehadiran hari ini sudah tersimpan.'
        : state.sudahCheckIn
            ? 'Lakukan check-out saat jam kerja selesai.'
            : 'Ikuti langkah singkat di bawah. Pastikan lokasi dan foto sudah siap.';
    final warna = sudahSelesai
        ? AppColors.success
        : state.sudahCheckIn
            ? AppColors.primary
            : AppColors.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              sudahSelesai
                  ? LucideIcons.circleCheck
                  : state.sudahCheckIn
                      ? LucideIcons.briefcase
                      : LucideIcons.hand,
              color: warna,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: TextStyle(
                    color: warna,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deskripsi,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedLocation(AbsensiState state) {
    final lokasi = state.lokasiDipilih!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.mapPinCheck,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOKASI ABSENSI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lokasi.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!state.sudahCheckIn)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ref.read(absensiProvider.notifier).gantiLokasi();
                },
                icon: const Icon(LucideIcons.arrowLeftRight, size: 15),
                label: const Text('Ganti lokasi'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNextActionCard(AbsensiState state) {
    IconData icon;
    String judul;
    String pesan;
    Color warna;

    if (!state.lokasiAktif || state.posisiSaatIni == null) {
      icon = LucideIcons.locateFixed;
      judul = 'Mencari lokasi Anda';
      pesan = 'Pastikan GPS aktif. Tunggu sampai posisi ditemukan.';
      warna = AppColors.warning;
    } else if (!state.akurasiGpsValid) {
      icon = LucideIcons.scanSearch;
      judul = 'Tingkatkan akurasi GPS';
      pesan =
          'Aktifkan Precise/Lokasi Akurat dan tunggu akurasi maksimal 50 meter.';
      warna = AppColors.warning;
    } else if (!state.dalamJangkauan) {
      icon = LucideIcons.navigation;
      judul = 'Mendekat ke lokasi absensi';
      pesan = 'Posisi Anda belum berada dalam radius site yang dipilih.';
      warna = AppColors.error;
    } else if (state.fotoSelfie == null) {
      icon = LucideIcons.camera;
      judul = 'Ambil foto selfie';
      pesan = 'Foto diperlukan sebelum absensi dapat disimpan.';
      warna = AppColors.primary;
    } else if (state.sedangMemproses) {
      icon = LucideIcons.loaderCircle;
      judul = 'Menyimpan absensi';
      pesan = 'Jangan tutup aplikasi sampai proses selesai.';
      warna = AppColors.primary;
    } else {
      icon = state.bisaCheckOut ? LucideIcons.logOut : LucideIcons.logIn;
      judul = state.bisaCheckOut ? 'Siap check-out' : 'Siap check-in';
      pesan = 'Semua persyaratan terpenuhi. Tekan tombol absensi di bawah.';
      warna = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warna.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: warna, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: TextStyle(
                    color: warna,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pesan,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
