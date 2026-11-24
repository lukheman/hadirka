import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/notifications_provider.dart';

class LayarNotifikasi extends ConsumerWidget {
  const LayarNotifikasi({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'attendance':
        return LucideIcons.checkCircle;
      case 'attendance_late':
        return LucideIcons.clockAlert;
      case 'leave':
        return LucideIcons.calendar;
      case 'system':
      default:
        return LucideIcons.bell;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'attendance':
        return AppColors.success;
      case 'attendance_late':
        return AppColors.error;
      case 'leave':
        return AppColors.primary;
      case 'system':
      default:
        return AppColors.warning;
    }
  }

  Color _getIconBg(String type) {
    switch (type) {
      case 'attendance':
        return AppColors.successBg;
      case 'attendance_late':
        return AppColors.errorBg;
      case 'leave':
        return AppColors.primaryContainer;
      case 'system':
      default:
        return AppColors.warningBg;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotifCountProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: AppColors.surface.withOpacity(0.85)),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text(
                'Pusat Notifikasi',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount Baru',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (notifications.any((n) => !n.isRead))
            IconButton(
              tooltip: 'Tandai Semua Dibaca',
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              icon: const Icon(LucideIcons.checkCheck,
                  size: 20, color: AppColors.primary),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.bellOff,
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Notifikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Notifikasi presensi dan status pengajuan akan tampil di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(notificationsProvider.notifier)
                    .refreshNotifications();
              },
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 100, bottom: 40),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderLight,
                ),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return ItemNotifikasi(
                    ikon: _getIcon(notif.type),
                    judul: notif.title,
                    pesan: notif.message,
                    waktu: notif.time,
                    sudahDibaca: notif.isRead,
                    warnaIkon: _getIconColor(notif.type),
                    latarIkon: _getIconBg(notif.type),
                    onTap: () {
                      ref
                          .read(notificationsProvider.notifier)
                          .markAsRead(notif.id);
                    },
                  );
                },
              ),
            ),
    );
  }
}

class ItemNotifikasi extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String pesan;
  final String waktu;
  final bool sudahDibaca;
  final Color warnaIkon;
  final Color latarIkon;
  final VoidCallback onTap;

  const ItemNotifikasi({
    super.key,
    required this.ikon,
    required this.judul,
    required this.pesan,
    required this.waktu,
    required this.sudahDibaca,
    required this.warnaIkon,
    required this.latarIkon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: sudahDibaca
            ? AppColors.surface
            : AppColors.surfaceContainerHigh.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: latarIkon,
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, color: warnaIkon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          judul,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight:
                                sudahDibaca ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (!sudahDibaca) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pesan,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    waktu,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
