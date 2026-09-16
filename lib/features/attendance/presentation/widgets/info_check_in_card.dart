import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/absensi_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/absensi_provider.dart';


class InfoCheckInCard extends StatelessWidget {
  final AbsensiState state;

  const InfoCheckInCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final dataIn = state.dataCheckIn!;
    final waktuIn = dataIn.waktu;
    final jamIn = AbsensiConfig.formatJamMenit(waktuIn);

    final isTerlambat = dataIn.statusKetepatan == 'terlambat';
    final statusLabel = isTerlambat ? 'Terlambat' : 'Tepat Waktu';
    final statusColor = isTerlambat ? AppColors.error : AppColors.success;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isTerlambat ? AppColors.errorBg : AppColors.successBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(
                  isTerlambat ? LucideIcons.alertCircle : LucideIcons.checkCircle2,
                  size: 22,
                  color: statusColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STATUS PRESENSI HARI INI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Absen Masuk Berhasil ($statusLabel)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: LucideIcons.logIn,
                        label: 'Jam Masuk',
                        value: '$jamIn WITA',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        icon: LucideIcons.logOut,
                        label: 'Jam Keluar',
                        value: state.sudahCheckOut && state.dataCheckOut != null
                            ? '${AbsensiConfig.formatJamMenit(state.dataCheckOut!.waktu)} WITA'
                            : 'Belum Out',
                        color: state.sudahCheckOut ? AppColors.success : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (state.sudahCheckOut) ...[
                      Expanded(
                        child: _buildInfoItem(
                          icon: LucideIcons.clock,
                          label: 'Total Jam Kerja',
                          value: state.durasiKerjaTeks,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: _buildInfoItem(
                        icon: LucideIcons.badgeCheck,
                        label: 'Status Ketepatan',
                        value: statusLabel,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.border),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi Absen',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dataIn.namaLokasi,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
