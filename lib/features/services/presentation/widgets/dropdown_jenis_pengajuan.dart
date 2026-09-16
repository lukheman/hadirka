import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';


class DropdownJenisPengajuan extends StatelessWidget {
  final String jenisTerpilih;
  final List<String> daftarJenis;
  final ValueChanged<String?> onChanged;

  const DropdownJenisPengajuan({
    super.key,
    required this.jenisTerpilih,
    required this.daftarJenis,
    required this.onChanged,
  });

  IconData _getIconForJenis(String jenis) {
    if (jenis.contains('SKS') || jenis.contains('Sakit')) {
      return LucideIcons.stethoscope;
    } else if (jenis.contains('Cuti')) {
      return LucideIcons.palmtree;
    }
    return LucideIcons.fileText;
  }

  @override
  Widget build(BuildContext context) {
    final validValue = daftarJenis.contains(jenisTerpilih) ? jenisTerpilih : daftarJenis.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validValue,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, color: AppColors.primary),
          items: daftarJenis.map((String nilai) {
            final icon = _getIconForJenis(nilai);
            return DropdownMenuItem<String>(
              value: nilai,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      nilai,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
