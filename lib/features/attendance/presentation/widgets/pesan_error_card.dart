import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';


class PesanErrorCard extends StatelessWidget {
  final String pesan;
  final VoidCallback onMuatUlangGps;

  const PesanErrorCard({
    super.key,
    required this.pesan,
    required this.onMuatUlangGps,
  });

  @override
  Widget build(BuildContext context) {
    final perluPengaturanLokasi = pesan.toLowerCase().contains('precise') ||
        pesan.toLowerCase().contains('approximate') ||
        pesan.toLowerCase().contains('akurasi') ||
        pesan.toLowerCase().contains('perkiraan');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.triangleAlert,
                  size: 20, color: AppColors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pesan,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onMuatUlangGps,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Muat Ulang GPS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (perluPengaturanLokasi) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => openAppSettings(),
              icon: const Icon(LucideIcons.settings, size: 16),
              label: const Text('Buka Pengaturan Lokasi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
