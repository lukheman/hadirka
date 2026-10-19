import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notification.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/data/model_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/model_profil.dart';
import '../providers/profil_provider.dart';
import 'widgets/dialog_ganti_pass.dart';
import 'widgets/modal_edit_profil.dart';

class LayarProfil extends ConsumerWidget {
  const LayarProfil({super.key});

  void _bukaModalEditProfil(BuildContext context, ProfilUser profil) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ModalEditProfil(profil: profil),
    );
  }

  void _bukaDialogGantiPass(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DialogGantiPass(),
    );
  }

  Future<void> _prosesPilihFoto(
      BuildContext context, WidgetRef ref, ImageSource source) async {
    Navigator.pop(context);
    try {
      final res =
          await ref.read(profilProvider.notifier).pickFotoProfil(source);
      if (res != null) {
        final bytes = res['bytes'] as Uint8List;
        final file = res['file'] as File?;
        await ref.read(profilProvider.notifier).setFotoProfilBytes(bytes, file);
      }
    } catch (e) {
      debugPrint('Error _prosesPilihFoto: $e');
    }
  }

  void _bukaPilihanFoto(BuildContext context, WidgetRef ref) {
    final profil = ref.read(profilProvider);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ubah Foto Profil',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: AppColors.primary),
              title: const Text('Ambil Foto Kamera',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => _prosesPilihFoto(context, ref, ImageSource.camera),
            ),
            ListTile(
              leading:
                  const Icon(LucideIcons.image, color: AppColors.secondary),
              title: const Text('Pilih dari Galeri',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => _prosesPilihFoto(context, ref, ImageSource.gallery),
            ),
            if (profil.hasFoto) ...[
              const Divider(color: AppColors.border),
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: AppColors.error),
                title: const Text('Hapus Foto Profil',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ref.read(profilProvider.notifier).hapusFotoProfil();
                    if (context.mounted) {
                      AppNotification.showInfo(
                          context, 'Foto profil berhasil dihapus.');
                    }
                  } catch (err) {
                    if (context.mounted) {
                      AppNotification.showError(context,
                          'Gagal menghapus foto profil: ${err.toString()}');
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _konfirmasiLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(LucideIcons.logOut, color: AppColors.error, size: 22),
            SizedBox(width: 10),
            Text('Konfirmasi Keluar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi Absensi Indoteknik Prima Mekongga?',
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL',
                style: TextStyle(color: AppColors.secondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('KELUAR',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

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
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userPen, color: AppColors.primary),
            tooltip: 'Edit Profil',
            onPressed: () => _bukaModalEditProfil(context, profil),
          )
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 1100,
        child: isMobile
            ? ListView(
                padding: const EdgeInsets.only(
                    top: 100, left: 20, right: 20, bottom: 100),
                children: [
                  HeaderProfil(
                    profil: profil,
                    onUbahFoto: () => _bukaPilihanFoto(context, ref),
                  ),
                  const SizedBox(height: 24),
                  KartuAksiProfil(
                    profil: profil,
                    onEditProfil: () => _bukaModalEditProfil(context, profil),
                    onGantiPass: () => _bukaDialogGantiPass(context),
                    onToggleNotifikasi: (val) {
                      ref.read(profilProvider.notifier).toggleNotifikasi(val);
                    },
                  ),
                  const SizedBox(height: 20),
                  KartuInformasi(
                    judul: 'INFORMASI PRIBADI',
                    ikon: LucideIcons.user,
                    anak: [
                      BarisInformasi(label: 'NIK', nilai: profil.nik),
                      const Divider(height: 1, color: AppColors.border),
                      BarisInformasi(
                          label: 'Jenis Kelamin', nilai: profil.jenisKelamin),
                      const Divider(height: 1, color: AppColors.border),
                      BarisInformasi(
                          label: 'No. WhatsApp/HP', nilai: profil.noHp),
                      const Divider(height: 1, color: AppColors.border),
                      BarisInformasi(label: 'Alamat', nilai: profil.alamat),
                    ],
                  ),
                  const SizedBox(height: 20),
                  KartuInformasi(
                    judul: 'INFORMASI PEKERJAAN',
                    ikon: LucideIcons.briefcase,
                    anak: [
                      BarisInformasi(label: 'Jabatan', nilai: profil.jabatan),
                      const Divider(height: 1, color: AppColors.border),
                      BarisInformasi(
                          label: 'Departemen', nilai: profil.departemen),
                      const Divider(height: 1, color: AppColors.border),
                      BarisInformasi(
                          label: 'Tanggal Masuk', nilai: profil.tanggalMasuk),
                      const Divider(height: 1, color: AppColors.border),
                      BarisStatus(
                          label: 'Status Kepegawaian',
                          nilai: profil.statusKepegawaian),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _konfirmasiLogout(context, ref),
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    label: const Text(
                      'KELUAR DARI AKUN',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorBg,
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 100, left: 24, right: 24, bottom: 60),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          HeaderProfil(
                            profil: profil,
                            onUbahFoto: () => _bukaPilihanFoto(context, ref),
                          ),
                          const SizedBox(height: 24),
                          KartuAksiProfil(
                            profil: profil,
                            onEditProfil: () =>
                                _bukaModalEditProfil(context, profil),
                            onGantiPass: () => _bukaDialogGantiPass(context),
                            onToggleNotifikasi: (val) {
                              ref
                                  .read(profilProvider.notifier)
                                  .toggleNotifikasi(val);
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _konfirmasiLogout(context, ref),
                              icon: const Icon(LucideIcons.logOut, size: 18),
                              label: const Text(
                                'KELUAR DARI AKUN',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorBg,
                                foregroundColor: AppColors.error,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          KartuInformasi(
                            judul: 'INFORMASI PRIBADI',
                            ikon: LucideIcons.user,
                            anak: [
                              BarisInformasi(label: 'NIK', nilai: profil.nik),
                              const Divider(height: 1, color: AppColors.border),
                              BarisInformasi(
                                  label: 'Jenis Kelamin',
                                  nilai: profil.jenisKelamin),
                              const Divider(height: 1, color: AppColors.border),
                              BarisInformasi(
                                  label: 'No. WhatsApp/HP', nilai: profil.noHp),
                              const Divider(height: 1, color: AppColors.border),
                              BarisInformasi(
                                  label: 'Alamat', nilai: profil.alamat),
                            ],
                          ),
                          const SizedBox(height: 24),
                          KartuInformasi(
                            judul: 'INFORMASI PEKERJAAN',
                            ikon: LucideIcons.briefcase,
                            anak: [
                              BarisInformasi(
                                  label: 'Jabatan', nilai: profil.jabatan),
                              const Divider(height: 1, color: AppColors.border),
                              BarisInformasi(
                                  label: 'Departemen',
                                  nilai: profil.departemen),
                              const Divider(height: 1, color: AppColors.border),
                              BarisInformasi(
                                  label: 'Tanggal Masuk',
                                  nilai: profil.tanggalMasuk),
                              const Divider(height: 1, color: AppColors.border),
                              BarisStatus(
                                  label: 'Status Kepegawaian',
                                  nilai: profil.statusKepegawaian),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class HeaderProfil extends ConsumerWidget {
  final ProfilUser profil;
  final VoidCallback onUbahFoto;

  const HeaderProfil({
    super.key,
    required this.profil,
    required this.onUbahFoto,
  });

  String _getInitial(String name) {
    if (name.isEmpty) return 'K';
    return name.trim()[0].toUpperCase();
  }

  Widget _buildFallbackAvatar(ProfilUser profil) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.onPrimaryFixed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _getInitial(profil.nama),
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(ProfilUser profil, UserAccount? authUser) {
    if (profil.fotoProfilBytes != null && profil.fotoProfilBytes!.isNotEmpty) {
      return Image.memory(
        profil.fotoProfilBytes!,
        key: ValueKey('${profil.nik}_${profil.fotoProfilBytes?.length}'),
        fit: BoxFit.cover,
        width: 110,
        height: 110,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _buildFallbackAvatar(profil),
      );
    }
    if (profil.fotoProfil != null && profil.fotoProfil!.existsSync()) {
      return Image.file(
        profil.fotoProfil!,
        key: ValueKey('${profil.nik}_file'),
        fit: BoxFit.cover,
        width: 110,
        height: 110,
        errorBuilder: (_, __, ___) => _buildFallbackAvatar(profil),
      );
    }
    if (authUser?.fotoProfil != null && authUser!.fotoProfil!.isNotEmpty) {
      try {
        final bytes = base64Decode(authUser.fotoProfil!);
        if (bytes.isNotEmpty) {
          return Image.memory(
            bytes,
            key: ValueKey('${profil.nik}_auth'),
            fit: BoxFit.cover,
            width: 110,
            height: 110,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _buildFallbackAvatar(profil),
          );
        }
      } catch (_) {}
    }
    return _buildFallbackAvatar(profil);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authProvider).user;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarImage(profil, authUser),
              ),
            ),
            GestureDetector(
              onTap: onUbahFoto,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.camera,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          profil.nama,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profil.jabatan,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimaryFixed,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profil.departemen,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class KartuAksiProfil extends StatelessWidget {
  final ProfilUser profil;
  final VoidCallback onEditProfil;
  final VoidCallback onGantiPass;
  final ValueChanged<bool> onToggleNotifikasi;

  const KartuAksiProfil({
    super.key,
    required this.profil,
    required this.onEditProfil,
    required this.onGantiPass,
    required this.onToggleNotifikasi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.userPen,
                    size: 18, color: AppColors.primary),
              ),
              title: const Text('Edit Data Pribadi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              subtitle: const Text('Ubah Nama, No. HP, & Alamat',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant)),
              trailing: const Icon(LucideIcons.chevronRight,
                  size: 18, color: AppColors.secondary),
              onTap: onEditProfil,
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.keyRound,
                    size: 18, color: AppColors.secondary),
              ),
              title: const Text('Ganti Kata Kunci',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              subtitle: const Text('Pengaturan keamanan & password akun',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant)),
              trailing: const Icon(LucideIcons.chevronRight,
                  size: 18, color: AppColors.secondary),
              onTap: onGantiPass,
            ),
            const Divider(height: 1, color: AppColors.border),
            SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.bellRing,
                    size: 18, color: AppColors.success),
              ),
              title: const Text('Notifikasi Presensi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              subtitle: const Text('Ingatkan pengingat jam masuk & keluar',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant)),
              value: profil.notifikasiAktif,
              activeColor: AppColors.primary,
              onChanged: onToggleNotifikasi,
            ),
          ],
        ),
      ),
    );
  }
}

class KartuInformasi extends StatelessWidget {
  final String judul;
  final IconData ikon;
  final List<Widget> anak;

  const KartuInformasi({
    super.key,
    required this.judul,
    required this.ikon,
    required this.anak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(ikon, size: 16, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              judul,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: anak,
          ),
        ),
      ],
    );
  }
}

class BarisInformasi extends StatelessWidget {
  final String label;
  final String nilai;

  const BarisInformasi({
    super.key,
    required this.label,
    required this.nilai,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarisStatus extends StatelessWidget {
  final String label;
  final String nilai;

  const BarisStatus({
    super.key,
    required this.label,
    required this.nilai,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.onSurfaceVariant)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              nilai,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
