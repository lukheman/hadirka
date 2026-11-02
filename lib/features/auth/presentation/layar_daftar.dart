import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notification.dart';
import '../providers/auth_provider.dart';

class LayarDaftar extends ConsumerStatefulWidget {
  const LayarDaftar({super.key});

  @override
  ConsumerState<LayarDaftar> createState() => _LayarDaftarState();
}

class _LayarDaftarState extends ConsumerState<LayarDaftar> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _passwordHidden = true;
  bool _confirmationHidden = true;
  bool _identifierVerified = false;
  String? _verifiedIdentifier;
  String? _verifiedNik;
  String? _verifiedNikKtp;
  String _verifiedName = '';
  String _verifiedPhone = '';

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _checkIdentifier() async {
    FocusScope.of(context).unfocus();
    if (_identifierController.text.trim().isEmpty) {
      _showError('NIK karyawan / NIK KTP wajib diisi.');
      return;
    }

    final result = await ref
        .read(authProvider.notifier)
        .checkActivation(_identifierController.text.trim());
    if (!mounted || result == null) return;

    final data = result['data'] is Map
        ? Map<String, dynamic>.from(result['data'] as Map)
        : result;
    setState(() {
      _identifierVerified = true;
      final nik = (data['nik_karyawan'] ?? data['nik'] ?? '').toString();
      _verifiedNik = nik.trim().isEmpty ? null : nik.toUpperCase();
      final nikKtp = (data['nik_ktp'] ?? '').toString();
      _verifiedNikKtp = nikKtp.trim().isEmpty ? null : nikKtp;
      _verifiedIdentifier = (_verifiedNik ?? _verifiedNikKtp ??
              _identifierController.text)
              .toString()
              .toUpperCase();
      _verifiedName = (data['nama'] ?? '').toString();
      _verifiedPhone = (data['noHp'] ?? '').toString();
    });
  }

  Future<void> _activateAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_identifierVerified || _verifiedIdentifier == null) return;

    final success = await ref.read(authProvider.notifier).register(
          username: _verifiedIdentifier!,
          nik: _verifiedNik,
          nama: _verifiedName,
          email: '${_verifiedIdentifier!.toLowerCase()}@ipm.local',
          noHp: _verifiedPhone,
          jabatan: '-',
          departemen: '-',
          password: _passwordController.text,
        );

    if (!mounted || !success) return;
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    AppNotification.showSuccess(
      context,
      'Aktivasi berhasil. Silakan login dengan password baru.',
    );
    context.go('/login');
  }

  void _showError(String message) {
    AppNotification.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.onSurface),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Aktivasi Akun',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                   'Masukkan NIK karyawan atau NIK KTP yang sudah didaftarkan HRD.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                if (authState.errorMessage != null) ...[
                  _MessageBox(
                    message: authState.errorMessage!,
                    color: AppColors.error,
                    background: AppColors.errorBg,
                    icon: LucideIcons.alertCircle,
                  ),
                  const SizedBox(height: 20),
                ],
                const Text(
                   'NIK Karyawan / NIK KTP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _identifierController,
                  enabled: !_identifierVerified && !authState.isLoading,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _inputDecoration(
                     hint: 'Contoh: IPM-00001 atau nomor KTP',
                    icon: LucideIcons.user,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                       ? 'NIK karyawan atau NIK KTP wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                if (!_identifierVerified)
                  ElevatedButton.icon(
                    onPressed: authState.isLoading ? null : _checkIdentifier,
                    icon: authState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(LucideIcons.search, size: 18),
                    label: const Text(
                      'CEK DATA KARYAWAN',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: _buttonStyle(),
                  ),
                if (_identifierVerified) ...[
                  _MessageBox(
                    message: 'Data ditemukan: $_verifiedName\n'
                        '${_verifiedNik == null ? '' : 'NIK: $_verifiedNik\n'}\n'
                        '${_verifiedNikKtp == null ? '' : 'NIK KTP: $_verifiedNikKtp\n'}\n'
                        'Buat password untuk mengaktifkan akun.',
                    color: AppColors.success,
                    background: AppColors.successBg,
                    icon: LucideIcons.checkCircle2,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Password Baru',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _passwordHidden,
                    decoration: _inputDecoration(
                      hint: 'Minimal 6 karakter',
                      icon: LucideIcons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordHidden
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        onPressed: () =>
                            setState(() => _passwordHidden = !_passwordHidden),
                      ),
                    ),
                    validator: (value) => value == null || value.length < 6
                        ? 'Password minimal 6 karakter'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Konfirmasi Password',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmationController,
                    obscureText: _confirmationHidden,
                    decoration: _inputDecoration(
                      hint: 'Ulangi password',
                      icon: LucideIcons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmationHidden
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        onPressed: () => setState(
                            () => _confirmationHidden = !_confirmationHidden),
                      ),
                    ),
                    validator: (value) => value != _passwordController.text
                        ? 'Konfirmasi password tidak cocok'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _activateAccount,
                    style: _buttonStyle(),
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
                            'AKTIFKAN AKUN',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => setState(() {
                              _identifierVerified = false;
                              _verifiedIdentifier = null;
                              _verifiedNik = null;
                              _verifiedNikKtp = null;
                              _passwordController.clear();
                              _confirmationController.clear();
                            }),
                     child: const Text('GANTI NIK'),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Masuk di Sini',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppColors.secondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;
  final Color color;
  final Color background;
  final IconData icon;

  const _MessageBox({
    required this.message,
    required this.color,
    required this.background,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
