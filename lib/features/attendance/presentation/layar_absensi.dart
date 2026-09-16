import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notification.dart';
import '../data/lokasi_provider.dart';
import '../providers/absensi_provider.dart';
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

class _LayarAbsensiState extends ConsumerState<LayarAbsensi>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(absensiProvider.notifier).mulaiPantauLokasi();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(absensiProvider);
    final daftarLokasi = ref.watch(lokasiAbsensiProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: AppColors.surface.withOpacity(0.8)),
          ),
        ),
        title: const Text(
          'Absensi Berbasis Lokasi',
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
            tooltip: 'Muat Ulang GPS',
            onPressed: () {
              ref.read(absensiProvider.notifier).mulaiPantauLokasi();
              AppNotification.showInfo(context, 'Mencari lokasi GPS ulang...');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              if (state.lokasiDipilih == null) ...[
                PilihanLokasiCard(
                  daftarLokasi: daftarLokasi,
                  lokasiDipilih: state.lokasiDipilih,
                  onPilihLokasi: (lokasi) {
                    ref.read(absensiProvider.notifier).pilihLokasi(lokasi);
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.4), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.mapPinCheck,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LOKASI PRESENSI TERPILIH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.lokasiDipilih!.nama,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!state.sudahCheckIn)
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(absensiProvider.notifier)
                                .gantiLokasi();
                          },
                          icon: const Icon(LucideIcons.arrowLeftRight, size: 14),
                          label: const Text('GANTI LOKASI'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                JamAbsensiCard(state: state),
                const SizedBox(height: 16),
                MapCard(
                  state: state,
                  pulseAnimation: _pulseAnimation,
                ),
                const SizedBox(height: 16),
                StatusJarakCard(state: state),
                const SizedBox(height: 16),
                FotoSelfieCard(
                  state: state,
                  onAmbilFoto: () {
                    ref.read(absensiProvider.notifier).ambilFotoSelfie();
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

              if (state.pesanError != null) ...[
                const SizedBox(height: 16),
                PesanErrorCard(
                  pesan: state.pesanError!,
                  onMuatUlangGps: () {
                    ref.read(absensiProvider.notifier).mulaiPantauLokasi();
                  },
                ),
              ],
              if (state.sudahCheckIn && state.dataCheckIn != null) ...[
                const SizedBox(height: 16),
                InfoCheckInCard(state: state),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
