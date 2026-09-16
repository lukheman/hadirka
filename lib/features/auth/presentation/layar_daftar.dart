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
  final _usernameController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _jabatanController = TextEditingController(text: 'Staff Lapangan');
  final _departemenController = TextEditingController(text: 'Operasional');
  final _passwordController = TextEditingController();
  final _konfirmasiPassController = TextEditingController();
  bool _sembunyikanPass = true;
  bool _sembunyikanKonfirmasi = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _jabatanController.dispose();
    _departemenController.dispose();
    _passwordController.dispose();
    _konfirmasiPassController.dispose();
    super.dispose();
  }

  Future<void> _prosesDaftar() async {
    if (_formKey.currentState!.validate()) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Pendaftaran',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: const Text(
              'Apakah Anda yakin data yang dimasukkan sudah benar dan ingin mendaftar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.secondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Ya, Daftar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final success = await ref.read(authProvider.notifier).register(
            username: _usernameController.text.trim(),
            nama: _namaController.text.trim(),
            email: _emailController.text.trim(),
            noHp: _noHpController.text.trim(),
            jabatan: _jabatanController.text.trim(),
            departemen: _departemenController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (success && mounted) {

        ref.read(authProvider.notifier).logout();

        AppNotification.showSuccess(
          context,
          'Pendaftaran berhasil! Silakan masuk menggunakan akun tersebut.',
        );

        context.go('/login');
      }
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pendaftaran',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Buat akun karyawan untuk mengakses sistem presensi & layanan TJS.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),

                
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

                
                const Text('NIK Karyawan',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration(
                    hint: 'Masukkan NIK Karyawan',
                    icon: LucideIcons.user,
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'NIK wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                
                const Text('Nama Lengkap',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _namaController,
                  decoration: _inputDecoration(
                    hint: 'Masukkan nama lengkap',
                    icon: LucideIcons.user,
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Nama lengkap wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                
                const Text('Alamat Email',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    hint: 'nama@tjs.co.id',
                    icon: LucideIcons.mail,
                  ),
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Alamat email tidak valid'
                      : null,
                ),
                const SizedBox(height: 16),

                const Text('Nomor WhatsApp / HP',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    hint: '0812-3456-7890',
                    icon: LucideIcons.phone,
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Nomor HP wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),


                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jabatan',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _jabatanController.text,
                            decoration: _inputDecoration(
                              hint: 'Jabatan',
                              icon: LucideIcons.briefcase,
                            ),
                            icon: const Icon(LucideIcons.chevronDown,
                                size: 18, color: AppColors.secondary),
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.onSurface),
                            items: [
                              'Staff Lapangan',
                              'Staff Kantor',
                              'Supervisor',
                              'Manager',
                              'Direktur'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _jabatanController.text = newValue;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Departemen',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _departemenController.text,
                            decoration: _inputDecoration(
                              hint: 'Departemen',
                              icon: LucideIcons.building,
                            ),
                            icon: const Icon(LucideIcons.chevronDown,
                                size: 18, color: AppColors.secondary),
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.onSurface),
                            items: [
                              'Operasional',
                              'HRD',
                              'Keuangan',
                              'IT',
                              'Marketing',
                              'Produksi'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _departemenController.text = newValue;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                
                const Text('Kata Kunci (Password)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _sembunyikanPass,
                  decoration: _inputDecoration(
                    hint: 'Minimal 6 karakter',
                    icon: LucideIcons.lock,
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
                  ),
                  validator: (val) => val == null || val.length < 6
                      ? 'Password minimal 6 karakter'
                      : null,
                ),
                const SizedBox(height: 16),

                
                const Text('Konfirmasi Kata Kunci',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _konfirmasiPassController,
                  obscureText: _sembunyikanKonfirmasi,
                  decoration: _inputDecoration(
                    hint: 'Ulangi password',
                    icon: LucideIcons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _sembunyikanKonfirmasi
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _sembunyikanKonfirmasi = !_sembunyikanKonfirmasi;
                        });
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Konfirmasi password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _prosesDaftar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
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
                          'DAFTAR SEKARANG',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, letterSpacing: 1.0),
                        ),
                ),
                const SizedBox(height: 20),

                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah memiliki akun? ',
                        style: TextStyle(color: AppColors.onSurfaceVariant)),
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
