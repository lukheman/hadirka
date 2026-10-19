import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BarisDetailGaji extends StatelessWidget {
  final String label;
  final String nilai;
  final bool adalahPotongan;
  final bool teksTebal;

  const BarisDetailGaji({
    super.key,
    required this.label,
    required this.nilai,
    this.adalahPotongan = false,
    this.teksTebal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: teksTebal
                  ? Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  nilai,
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            teksTebal ? FontWeight.w700 : FontWeight.w500,
                        color: adalahPotongan
                            ? AppColors.error
                            : AppColors.textPrimary,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
