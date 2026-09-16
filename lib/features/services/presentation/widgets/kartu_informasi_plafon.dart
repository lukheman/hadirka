import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class KartuInformasiPlafon extends StatelessWidget {
  const KartuInformasiPlafon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.info, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Plafon maksimal pinjaman Anda saat ini adalah Rp 15.000.000.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
