import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SliderPinjaman extends StatelessWidget {
  final double jumlah;
  final ValueChanged<double> onChanged;

  const SliderPinjaman({
    super.key,
    required this.jumlah,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: jumlah,
      min: 1000000,
      max: 15000000,
      divisions: 14,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
