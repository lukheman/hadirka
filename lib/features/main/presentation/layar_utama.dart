import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notification.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/update_service.dart';
import '../../attendance/providers/absensi_provider.dart';
import '../../notifications/providers/notifications_provider.dart';

class LayarUtama extends ConsumerStatefulWidget {
  const LayarUtama({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<LayarUtama> createState() => _LayarUtamaState();
}

class _LayarUtamaState extends ConsumerState<LayarUtama> {
  DateTime? _lastPressedAt;
  bool _updateCheckStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _updateCheckStarted) return;
      _updateCheckStarted = true;
      UpdateService.check(context);
    });
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    int unreadHomeCount = 0;
    bool needsCheckIn = false;
    bool hasLayananNotif = false;

    try {
      unreadHomeCount = ref.watch(unreadNotifCountProvider);
    } catch (_) {}

    try {
      final absensiState = ref.watch(absensiProvider);
      needsCheckIn = !absensiState.sudahCheckIn;
    } catch (_) {}

    try {
      final allNotifs = ref.watch(notificationsProvider);
      hasLayananNotif = allNotifs.any((n) =>
          !n.isRead &&
          (n.type == 'leave' || n.type == 'loan' || n.type == 'payslip'));
    } catch (_) {}

    Widget content;

    if (!isMobile) {
      content = Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: isDesktop,
              minExtendedWidth: 180,
              backgroundColor: AppColors.surfaceContainerLowest,
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              labelType: isDesktop
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo-ipm.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        LucideIcons.shieldCheck,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    if (isDesktop) ...[
                      const SizedBox(width: 10),
                      const Text(
                        'Absen Indoteknik Prima Mekongga',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              selectedIconTheme:
                  const IconThemeData(color: AppColors.primary, size: 24),
              unselectedIconTheme: const IconThemeData(
                  color: AppColors.onSurfaceVariant, size: 22),
              selectedLabelTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.primary,
              ),
              unselectedLabelTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
              destinations: [
                NavigationRailDestination(
                  icon: _buildBadgeIcon(LucideIcons.layoutDashboard,
                      badgeCount: unreadHomeCount, badgeColor: AppColors.error),
                  selectedIcon: _buildBadgeIcon(LucideIcons.layoutDashboard,
                      isSelected: true,
                      badgeCount: unreadHomeCount,
                      badgeColor: AppColors.error),
                  label: const Text('Home'),
                ),
                NavigationRailDestination(
                  icon: _buildBadgeIcon(LucideIcons.scanFace,
                      showDot: needsCheckIn, badgeColor: AppColors.warning),
                  selectedIcon: _buildBadgeIcon(LucideIcons.scanFace,
                      isSelected: true,
                      showDot: needsCheckIn,
                      badgeColor: AppColors.warning),
                  label: const Text('Absensi'),
                ),
                NavigationRailDestination(
                  icon: _buildBadgeIcon(LucideIcons.layoutGrid,
                      showDot: hasLayananNotif,
                      badgeColor: AppColors.hrAccentPurple),
                  selectedIcon: _buildBadgeIcon(LucideIcons.layoutGrid,
                      isSelected: true,
                      showDot: hasLayananNotif,
                      badgeColor: AppColors.hrAccentPurple),
                  label: const Text('Layanan'),
                ),
                NavigationRailDestination(
                  icon: const Icon(LucideIcons.user),
                  selectedIcon:
                      const Icon(LucideIcons.user, color: AppColors.primary),
                  label: const Text('Profil'),
                ),
              ],
            ),
            const VerticalDivider(
                thickness: 1, width: 1, color: AppColors.border),
            Expanded(child: widget.navigationShell),
          ],
        ),
      );
    } else {
      content = Scaffold(
        extendBody: true,
        body: widget.navigationShell,
        bottomNavigationBar: CustomFloatingNavBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _goBranch,
          homeUnreadCount: unreadHomeCount,
          needsCheckIn: needsCheckIn,
          hasLayananNotif: hasLayananNotif,
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (widget.navigationShell.currentIndex != 0) {
          _goBranch(0);
          return;
        }

        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          AppNotification.showInfo(
              context, 'Tekan sekali lagi untuk keluar dari aplikasi');
        } else {
          SystemNavigator.pop();
        }
      },
      child: content,
    );
  }

  Widget _buildBadgeIcon(IconData iconData,
      {bool isSelected = false,
      int badgeCount = 0,
      bool showDot = false,
      Color badgeColor = AppColors.primary}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          iconData,
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
        if (badgeCount > 0)
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        else if (showDot)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int homeUnreadCount;
  final bool needsCheckIn;
  final bool hasLayananNotif;

  const CustomFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.homeUnreadCount,
    required this.needsCheckIn,
    required this.hasLayananNotif,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.ipmOrange.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: LucideIcons.layoutDashboard,
                  activeIcon: LucideIcons.layoutDashboard,
                  label: 'Home',
                  badgeCount: homeUnreadCount,
                  badgeColor: AppColors.error,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: LucideIcons.scanFace,
                  activeIcon: LucideIcons.scanFace,
                  label: 'Absensi',
                  showDot: needsCheckIn,
                  badgeColor: AppColors.warning,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: LucideIcons.layoutGrid,
                  activeIcon: LucideIcons.layoutGrid,
                  label: 'Layanan',
                  showDot: hasLayananNotif,
                  badgeColor: AppColors.hrAccentPurple,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: LucideIcons.user,
                  activeIcon: LucideIcons.user,
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
    bool showDot = false,
    Color badgeColor = AppColors.primary,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withOpacity(0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -5,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                else if (showDot)
                  Positioned(
                    top: -2,
                    right: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
