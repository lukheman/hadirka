import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/absensi_provider.dart';


class FotoSelfieCard extends StatelessWidget {
  final AbsensiState state;
  final VoidCallback onAmbilFoto;
  final VoidCallback onHapusFoto;

  const FotoSelfieCard({
    super.key,
    required this.state,
    required this.onAmbilFoto,
    required this.onHapusFoto,
  });

  @override
  Widget build(BuildContext context) {
    final foto = state.fotoSelfie;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: foto != null
              ? AppColors.success.withOpacity(0.4)
              : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: foto != null
                      ? AppColors.successBg
                      : AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  foto != null ? LucideIcons.checkCircle2 : LucideIcons.camera,
                  size: 18,
                  color: foto != null ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VERIFIKASI FOTO SELFIE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                       foto != null ? 'Foto Selfie Berhasil Diambil' : 'Foto Belum Diambil',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (foto != null)
                IconButton(
                  onPressed: onHapusFoto,
                  icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                  tooltip: 'Hapus Foto',
                ),
            ],
          ),
          const SizedBox(height: 16),

          
          if (foto != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.file(
                      foto,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.checkCircle2, color: AppColors.accentGreen, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Foto Siap',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onAmbilFoto,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('AMBIL FOTO ULANG', style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ] else ...[
            InkWell(
              onTap: onAmbilFoto,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                       'Ketuk ikon kamera untuk mengambil foto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Wajib mengambil foto lokasi saat ini sebelum menekan tombol absen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
