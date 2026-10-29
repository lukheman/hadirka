import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/backend/backend_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_notification.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/model_profil.dart';
import '../../providers/profil_provider.dart';

class ModalEditProfil extends ConsumerStatefulWidget {
  final ProfilUser profil;

  const ModalEditProfil({super.key, required this.profil});

  @override
  ConsumerState<ModalEditProfil> createState() => _ModalEditProfilState();
}

class _ModalEditProfilState extends ConsumerState<ModalEditProfil> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;

  late TextEditingController _noHpController;
  late TextEditingController _alamatController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.profil.nama);

    _noHpController = TextEditingController(text: widget.profil.noHp);
    _alamatController = TextEditingController(text: widget.profil.alamat);
  }

  @override
  void dispose() {
    _namaController.dispose();

    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _simpanPembaruan() async {
    if (_formKey.currentState!.validate()) {
      final namaBaru = _namaController.text.trim();

      final noHpBaru = _noHpController.text.trim();
      final nik = widget.profil.nik;

      try {
        await ref.read(servicesRepositoryProvider).updateProfile({
          'nik': nik,
          'nama': namaBaru,
          'noHp': noHpBaru,
        });
      } catch (e) {
        if (mounted) {
          AppNotification.showError(context,
              'Gagal mengupdate database: ${e.toString().replaceAll('Exception: ', '')}');
        }
        return;
      }

      ref.read(profilProvider.notifier).updateProfil(
            nama: namaBaru,
            noHp: noHpBaru,
            alamat: widget.profil.alamat,
          );

      ref.read(authProvider.notifier).updateUser(
            nama: namaBaru,
            noHp: noHpBaru,
          );

      if (mounted) {
        Navigator.of(context).pop();
        AppNotification.showSuccess(
            context, 'Profil berhasil disimpan ke database!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.userPen,
                            size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Data Pribadi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _namaController,
                    decoration: _inputDecoration(
                      label: 'Nama Lengkap',
                      icon: LucideIcons.user,
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Nama tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _noHpController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      label: 'Nomor WhatsApp / HP',
                      icon: LucideIcons.phone,
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'No. HP tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _alamatController,
                    maxLines: 2,
                    decoration: _inputDecoration(
                      label: 'Alamat Tempat Tinggal',
                      icon: LucideIcons.mapPin,
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Alamat tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _simpanPembaruan,
                    icon: const Icon(LucideIcons.save, size: 18),
                    label: const Text(
                      'SIMPAN PERUBAHAN',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: AppColors.secondary),
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
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
