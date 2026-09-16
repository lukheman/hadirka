import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/backend/backend_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_notification.dart';
import '../../../auth/providers/auth_provider.dart';


class DialogGantiPass extends ConsumerStatefulWidget {
  const DialogGantiPass({super.key});

  @override
  ConsumerState<DialogGantiPass> createState() => _DialogGantiPassState();
}

class _DialogGantiPassState extends ConsumerState<DialogGantiPass> {
  final _formKey = GlobalKey<FormState>();
  final _passLamaController = TextEditingController();
  final _passBaruController = TextEditingController();
  final _konfirmasiPassController = TextEditingController();

  bool _sembunyikanPassLama = true;
  bool _sembunyikanPassBaru = true;
  bool _sembunyikanKonfirmasi = true;
  bool _sedangProses = false;

  @override
  void dispose() {
    _passLamaController.dispose();
    _passBaruController.dispose();
    _konfirmasiPassController.dispose();
    super.dispose();
  }

  Future<void> _simpanKataKunci() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      setState(() {
        _sedangProses = true;
      });

      try {
        final passLama = _passLamaController.text.trim();
        final passBaru = _passBaruController.text.trim();

        await ref.read(servicesRepositoryProvider).updatePassword(user.username, passLama, passBaru);

        if (mounted) {
          Navigator.of(context).pop();
          AppNotification.showSuccess(context, 'Password berhasil diubah!');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _sedangProses = false;
          });
          AppNotification.showError(context, 'Gagal mengubah password: ${e.toString().replaceAll('Exception: ', '')}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.shieldCheck,
                          size: 26, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ganti Kata Kunci',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gunakan kata kunci yang aman dan unik',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                
                const Text('KATA KUNCI SAAT INI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passLamaController,
                  obscureText: _sembunyikanPassLama,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(
                    hint: 'Masukkan kata kunci lama',
                    isObscure: _sembunyikanPassLama,
                    onToggle: () {
                      setState(() {
                        _sembunyikanPassLama = !_sembunyikanPassLama;
                      });
                    },
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Wajib diisi'
                      : null,
                ),
                const SizedBox(height: 18),

                
                const Text('KATA KUNCI BARU',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passBaruController,
                  obscureText: _sembunyikanPassBaru,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(
                    hint: 'Buat kata kunci baru',
                    isObscure: _sembunyikanPassBaru,
                    onToggle: () {
                      setState(() {
                        _sembunyikanPassBaru = !_sembunyikanPassBaru;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'Minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                
                const Text('KONFIRMASI KATA KUNCI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _konfirmasiPassController,
                  obscureText: _sembunyikanKonfirmasi,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(
                    hint: 'Ulangi kata kunci baru',
                    isObscure: _sembunyikanKonfirmasi,
                    onToggle: () {
                      setState(() {
                        _sembunyikanKonfirmasi = !_sembunyikanKonfirmasi;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val != _passBaruController.text) {
                      return 'Kata kunci tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: _sedangProses ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _sedangProses ? null : _simpanKataKunci,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _sedangProses
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'SIMPAN KATA KUNCI',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
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

  InputDecoration _inputDecoration({
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.border),
      prefixIcon: const Icon(LucideIcons.lock, size: 18, color: AppColors.secondary),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure ? LucideIcons.eyeOff : LucideIcons.eye,
          size: 18,
          color: AppColors.secondary,
        ),
        onPressed: onToggle,
        splashRadius: 20,
      ),
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}

