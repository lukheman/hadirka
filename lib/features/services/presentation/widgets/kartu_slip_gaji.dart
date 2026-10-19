import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../utils/periode_gaji.dart';
import 'modal_detail_slip_gaji.dart';

class KartuSlipGaji extends StatelessWidget {
  final Map<String, dynamic> slipData;

  const KartuSlipGaji({
    super.key,
    required this.slipData,
  });

  void _tampilkanDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ModalDetailSlipGaji(
          slipData: slipData,
        );
      },
    );
  }

  String _formatRupiah(num number) {
    final str = number
        .toInt()
        .toString()
        .replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return 'Rp $str';
  }

  @override
  Widget build(BuildContext context) {
    final periode = formatPeriodeGaji(slipData['periode']);
    final totalDiterima = slipData['totalDiterima'] ?? 0;
    final jumlah = _formatRupiah(totalDiterima);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periode,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jumlah,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.fileText,
                      color: AppColors.primary, size: 24),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          InkWell(
            onTap: () => _tampilkanDetailModal(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lihat Detail',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.arrowRight,
                      color: AppColors.primary, size: 16),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
