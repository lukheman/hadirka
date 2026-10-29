import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/absensi_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/absensi_provider.dart';

class JamAbsensiCard extends StatelessWidget {
  final AbsensiState state;

  const JamAbsensiCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final wita = state.waktuWitaSaatIni ?? AbsensiConfig.witaNow;
    final jamStr = AbsensiConfig.formatJamMenitDetik(wita);
    final statusKode = state.statusAbsensiKode;
    final statusLabel = state.statusAbsensiLabel;
    final jamMulai = state.dataCheckIn?.jamKerjaMulai ?? '08:00:00';
    final jamSelesai = state.dataCheckIn?.jamKerjaSelesai ?? '17:00:00';
    String jamPendek(String value) =>
        value.length >= 5 ? value.substring(0, 5) : value;

    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (statusKode) {
      case 'tepat_waktu':
      case 'sudah_selesai':
        statusColor = AppColors.success;
        statusBg = AppColors.successBg;
        statusIcon = LucideIcons.circleCheck;
        break;
      case 'sedang_bekerja':
        statusColor = AppColors.primary;
        statusBg = AppColors.primaryContainer.withOpacity(0.4);
        statusIcon = LucideIcons.briefcase;
        break;
      case 'terlambat':
        statusColor = AppColors.error;
        statusBg = AppColors.errorBg;
        statusIcon = LucideIcons.clockAlert;
        break;
      case 'belum_dimulai':
        statusColor = AppColors.warning;
        statusBg = AppColors.warningBg;
        statusIcon = LucideIcons.clock;
        break;
      case 'jam_operasional_berakhir':
      default:
        statusColor = AppColors.onSurfaceVariant;
        statusBg = AppColors.surfaceContainerHigh;
        statusIcon = LucideIcons.timerOff;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, size: 20, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'JAM OPERASIONAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${jamPendek(jamMulai)} - ${jamPendek(jamSelesai)} WITA',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      'Batas Tepat Waktu: ${jamPendek(jamMulai)} WITA',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.watch,
                        size: 15, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Waktu:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$jamStr WITA',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (state.keterlambatanMenit > 0 || state.sudahCheckOut) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (state.keterlambatanMenit > 0)
                  Expanded(
                    child: _buildMiniStat(
                      'Keterlambatan',
                      state.keterlambatanTeks,
                      LucideIcons.clockAlert,
                      AppColors.error,
                    ),
                  ),
                if (state.keterlambatanMenit > 0 && state.sudahCheckOut)
                  const SizedBox(width: 10),
                if (state.sudahCheckOut)
                  Expanded(
                    child: _buildMiniStat(
                      'Total Jam Kerja',
                      state.durasiKerjaTeks,
                      LucideIcons.timer,
                      AppColors.primary,
                    ),
                  ),
              ],
            ),
          ],
          if (state.keteranganJamAbsensi.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, size: 16, color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.keteranganJamAbsensi,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.9),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
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
