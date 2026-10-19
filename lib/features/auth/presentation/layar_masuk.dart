import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notification.dart';
import '../providers/auth_provider.dart';

class LayarMasuk extends ConsumerStatefulWidget {
  const LayarMasuk({super.key});

  @override
  ConsumerState<LayarMasuk> createState() => _LayarMasukState();
}

class _LayarMasukState extends ConsumerState<LayarMasuk> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _sembunyikanPass = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prosesLogin([String? username]) async {
    final identifier = username ?? _usernameController.text.trim();
    final password = _passwordController.text;

    if (username != null || _formKey.currentState!.validate()) {
      final ok = await ref.read(authProvider.notifier).login(
            identifier: identifier,
            password: password,
          );

      if (ok && mounted) {
        final authState = ref.read(authProvider);

        AppNotification.showSuccess(
          context,
          'Selamat datang kembali, ${authState.user?.nama ?? ""}!',
        );

        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo-ipm.png',
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.image,
                              color: AppColors.primary, size: 32),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.accentGreen, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'INDOTEKNIK PRIMA MEKONGGA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                const _TypewriterText(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk menggunakan NIK Anda.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const Text(
                  'ID Karyawan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan ID Karyawan',
                    prefixIcon: const Icon(LucideIcons.user,
                        size: 18, color: AppColors.secondary),
                    filled: true,
                    fillColor: AppColors.loginCard,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.ipmOrangeLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.ipmOrangeLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Masukkan ID Karyawan'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _sembunyikanPass,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Password',
                    prefixIcon: const Icon(LucideIcons.lock,
                        size: 18, color: AppColors.secondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _sembunyikanPass ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _sembunyikanPass = !_sembunyikanPass;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.loginCard,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.ipmOrangeLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.ipmOrangeLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Masukkan Password' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : () => _prosesLogin(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 6,
                    shadowColor: AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'MASUK KE SISTEM',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 4,
                  children: [
                    const Text(
                      'Belum punya akun?',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const _TypewriterText(this.text, {required this.style});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animateText();
  }

  void _animateText() async {
    while (mounted) {
      for (int i = 0; i < widget.text.length; i++) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        setState(() {
          _currentIndex++;
          _displayedText = widget.text.substring(0, _currentIndex);
        });
      }

      await Future.delayed(const Duration(seconds: 2));

      for (int i = widget.text.length; i > 0; i--) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        setState(() {
          _currentIndex--;
          _displayedText = widget.text.substring(0, _currentIndex);
        });
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}
