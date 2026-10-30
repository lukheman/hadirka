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
                if (state.sudahCheckIn && state.dataCheckIn != null) ...[
                  InfoCheckInCard(state: state),
                  const SizedBox(height: 16),
                ],
                StatusJarakCard(state: state),
                const SizedBox(height: 16),
                MapCard(
                  state: state,
                ),
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

}
