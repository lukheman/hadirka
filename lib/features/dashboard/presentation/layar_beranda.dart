import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../attendance/providers/absensi_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../profile/providers/profil_provider.dart';
import 'widgets/beranda_attendance_card.dart';
import 'widgets/beranda_calendar.dart';
import 'widgets/beranda_greeting.dart';
import 'widgets/beranda_quick_services.dart';
import 'widgets/beranda_recent_activity.dart';

class LayarBeranda extends ConsumerWidget {
  const LayarBeranda({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profil = ref.watch(profilProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: AppColors.surface.withOpacity(0.8)),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo-hadirka.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                LucideIcons.shieldCheck,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Home',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(unreadNotifCountProvider);
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.bell,
                      color: AppColors.onSurface,
                      size: 22,
                    ),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final authUser = ref.watch(authProvider).user;
              ImageProvider? bgImage;
              if (profil.fotoProfilBytes != null &&
                  profil.fotoProfilBytes!.isNotEmpty) {
                bgImage = MemoryImage(profil.fotoProfilBytes!);
              } else if (profil.fotoProfil != null &&
                  profil.fotoProfil!.existsSync()) {
                bgImage = FileImage(profil.fotoProfil!);
              } else if (authUser?.fotoProfil != null &&
                  authUser!.fotoProfil!.isNotEmpty) {
                try {
                  final bytes = base64Decode(authUser.fotoProfil!);
                  if (bytes.isNotEmpty) bgImage = MemoryImage(bytes);
                } catch (_) {}
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16, left: 4),
                child: InkWell(
                  onTap: () => context.go('/profile'),
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryFixed,
                    backgroundImage: bgImage,
                    child: bgImage == null
                        ? Text(
                            profil.nama.isNotEmpty
                                ? profil.nama.trim()[0].toUpperCase()
                                : 'K',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onPrimaryFixed,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(absensiProvider.notifier).muatUlangData();
          },
          child: ResponsiveContainer(
            maxWidth: 1200,
            padding: const EdgeInsets.all(20),
            child: isMobile
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      const BerandaGreeting(),
                      const SizedBox(height: 24),
                      const BerandaAttendanceCard(),
                      const SizedBox(height: 24),
                      const BerandaQuickServices(),
                      const SizedBox(height: 24),
                      const BerandaCalendar(),
                      const SizedBox(height: 24),
                      const BerandaRecentActivity(),
                      const SizedBox(height: 32),
                      _buildWatermark(),
                    ],
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        const BerandaGreeting(),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: const [
                                  BerandaAttendanceCard(),
                                  SizedBox(height: 24),
                                  BerandaQuickServices(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),

                            Expanded(
                              flex: 5,
                              child: Column(
                                children: const [
                                  BerandaCalendar(),
                                  SizedBox(height: 24),
                                  BerandaRecentActivity(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildWatermark(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatermark() {
    return Center(
      child: Opacity(
        opacity: 0.2,
        child: Icon(
          Icons.business,
          size: 96,
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}
