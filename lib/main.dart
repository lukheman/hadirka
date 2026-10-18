import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_config.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/permissions/presentation/halaman_izin_awal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(isOptional: true);
  } catch (e) {
    debugPrint('Gagal memuat .env, memakai nilai default: $e');
  }

  await ApiConfig.loadCustomUrl();
  final notificationService = NotificationService();
  await notificationService.init();

  debugPrint('Server API aktif: ${ApiConfig.baseUrl}');

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  static const _kunciIzinAwalSelesai = 'permission_setup_completed';
  bool? _izinAwalSelesai;

  @override
  void initState() {
    super.initState();
    _bacaStatusIzinAwal();
  }

  Future<void> _bacaStatusIzinAwal() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _izinAwalSelesai = prefs.getBool(_kunciIzinAwalSelesai) ?? false;
    });
  }

  Future<void> _selesaikanIzinAwal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kunciIzinAwalSelesai, true);
    if (mounted) setState(() => _izinAwalSelesai = true);
  }

  @override
  Widget build(BuildContext context) {
    final izinAwalSelesai = _izinAwalSelesai;

    if (izinAwalSelesai == null) {
      return MaterialApp(
        title: 'Absensi TJS',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const _HalamanMemuatIzin(),
      );
    }

    if (!izinAwalSelesai) {
      return MaterialApp(
        title: 'Absensi TJS',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: HalamanIzinAwal(onSelesai: _selesaikanIzinAwal),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Absensi TJS',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return child ?? const SizedBox();
      },
    );
  }
}

class _HalamanMemuatIzin extends StatelessWidget {
  const _HalamanMemuatIzin();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
