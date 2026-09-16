import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class KartuEstimasiAngsuran extends StatelessWidget {
  final double jumlahPinjaman;
  final int tenor;

  const KartuEstimasiAngsuran({
    super.key,
    required this.jumlahPinjaman,
    required this.tenor,
  });

  @override
  Widget build(BuildContext context) {
    final int angsuranBulanan = (jumlahPinjaman / tenor).toInt();
    final String angsuranFormat = angsuranBulanan
        .toString()
        .replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Estimasi Angsuran',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            'Rp $angsuranFormat/bln',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
