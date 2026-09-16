import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';


class LabelInput extends StatelessWidget {
  final String teks;

  const LabelInput({super.key, required this.teks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        teks,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
      ),
    );
  }
}
