import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/layar_masuk.dart';
import '../../features/auth/presentation/layar_daftar.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/main/presentation/layar_utama.dart';
import '../../features/dashboard/presentation/layar_beranda.dart';
import '../../features/attendance/presentation/layar_absensi.dart';
import '../../features/services/presentation/layar_layanan.dart';
import '../../features/services/presentation/layar_pengajuan_ketidakhadiran.dart';
import '../../features/services/presentation/layar_slip_gaji.dart';
import '../../features/services/presentation/layar_pengajuan_pinjaman.dart';
import '../../features/notifications/presentation/layar_notifikasi.dart';
import '../../features/profile/presentation/layar_profil.dart';


final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      
      if (!authState.isAuthenticated) {
        if (!isLoggingIn && !isRegistering) {
          return '/login';
        }
        return null;
      }

      
      if (isLoggingIn || isRegistering) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LayarMasuk(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const LayarDaftar(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return LayarUtama(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const LayarBeranda(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/attendance',
                builder: (context, state) => const LayarAbsensi(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/services',
                builder: (context, state) => const LayarLayanan(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const LayarProfil(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const LayarNotifikasi(),
      ),
      GoRoute(
        path: '/services/leave',
        builder: (context, state) => const LayarPengajuanKetidakhadiran(),
      ),
      GoRoute(
        path: '/services/payslip',
        builder: (context, state) => const LayarSlipGaji(),
      ),
      GoRoute(
        path: '/services/loan',
        builder: (context, state) => const LayarPengajuanPinjaman(),
      ),
    ],
  );
});
