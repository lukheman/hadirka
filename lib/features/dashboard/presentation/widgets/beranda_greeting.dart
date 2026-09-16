import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';

import '../../../profile/providers/profil_provider.dart';

class BerandaGreeting extends ConsumerWidget {
  const BerandaGreeting({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour < 15) {
      return 'Selamat Siang,';
    } else if (hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profil = ref.watch(profilProvider);
    final authState = ref.watch(authProvider);
    final nama = (profil.nama.isNotEmpty && profil.nama != 'Karyawan')
        ? profil.nama
        : (authState.user?.nama ?? 'Karyawan');
    final jabatan = (profil.jabatan.isNotEmpty && profil.jabatan != '-')
        ? profil.jabatan
        : (authState.user?.jabatan ?? 'Staf');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          nama,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: -0.01,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          jabatan,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
            letterSpacing: 0.05,
          ),
        ),
      ],
    );
  }
}
