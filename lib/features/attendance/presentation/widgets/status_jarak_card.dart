import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/absensi_provider.dart';

class StatusJarakCard extends ConsumerWidget {
  final AbsensiState state;

  const StatusJarakCard({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dalamJangkauan = state.dalamJangkauan;
    final targetLokasi = state.lokasiDipilih ?? state.lokasiTerdekat;
    final radius = targetLokasi?.radius ?? 0;
    final lokasiNama = targetLokasi?.nama ?? '-';
    final jarakTeks = state.jarakTerdekat != null
        ? '${state.jarakTerdekat!.toStringAsFixed(1)} meter'
        : '-';
    final akurasiTeks = state.akurasiGps != null
        ? '±${state.akurasiGps!.toStringAsFixed(1)}m ${state.akurasiGpsValid ? "(Akurat)" : "(Kurang Akurat)"}'
        : '-';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dalamJangkauan
              ? AppColors.success.withOpacity(0.35)
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: dalamJangkauan ? AppColors.successBg : AppColors.errorBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (dalamJangkauan
                                ? AppColors.success
                                : AppColors.error)
                            .withOpacity(0.2),
                    blurRadius: 3,
                      )
                    ],
                  ),
                  child: Icon(
                    dalamJangkauan
                        ? LucideIcons.checkCircle2
                        : LucideIcons.alertCircle,
                     size: 17,
                    color: dalamJangkauan ? AppColors.success : AppColors.error,
                  ),
                ),
                 const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dalamJangkauan
                            ? 'STATUS LOKASI: DALAM JANGKAUAN'
                            : 'STATUS LOKASI: DI LUAR JANGKAUAN',
                        style: TextStyle(
                           fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: dalamJangkauan
                              ? AppColors.success
                              : AppColors.error,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                _buildFieldRow(
                  icon: LucideIcons.building2,
                  label: 'Lokasi Presensi',
                  value: lokasiNama,
                  valueColor: AppColors.primary,
                  action: !state.sudahCheckIn
                      ? InkWell(
                          onTap: () {
                            ref.read(absensiProvider.notifier).gantiLokasi();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.arrowLeftRight,
                                    size: 12, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Ganti',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                const Divider(height: 18, color: AppColors.border),
                _buildFieldRow(
                  icon: LucideIcons.ruler,
                  label: 'Jarak ke Lokasi',
                  value: jarakTeks,
                  valueColor: dalamJangkauan
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const Divider(height: 18, color: AppColors.border),
                _buildFieldRow(
                  icon: LucideIcons.radar,
                  label: 'Radius Diizinkan',
                  value: '${radius.toStringAsFixed(0)} meter',
                  valueColor: AppColors.primary,
                ),
                const Divider(height: 18, color: AppColors.border),
                _buildFieldRow(
                  icon: LucideIcons.satellite,
                  label: 'Akurasi GPS',
                  value: akurasiTeks,
                  valueColor: state.akurasiGpsValid
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? action,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 8),
          action,
        ],
      ],
    );
  }

}
