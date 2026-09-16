import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OpsiTenor extends StatelessWidget {
  final int bulan;
  final int tenorTerpilih;
  final ValueChanged<int> onTap;

  const OpsiTenor({
    super.key,
    required this.bulan,
    required this.tenorTerpilih,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool dipilih = tenorTerpilih == bulan;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(bulan),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: dipilih ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: dipilih ? AppColors.primary : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            '$bulan Bln',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dipilih ? AppColors.onPrimary : AppColors.textPrimary,
                  fontWeight: dipilih ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }
}
