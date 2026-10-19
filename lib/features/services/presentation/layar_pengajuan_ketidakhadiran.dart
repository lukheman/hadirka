import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/backend/backend_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notification.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/bidang_tanggal.dart';
import 'widgets/dropdown_jenis_pengajuan.dart';
import 'widgets/unggah_berkas.dart';

class LayarPengajuanKetidakhadiran extends ConsumerStatefulWidget {
  const LayarPengajuanKetidakhadiran({super.key});

  @override
  ConsumerState<LayarPengajuanKetidakhadiran> createState() =>
      _StateLayarPengajuanKetidakhadiran();
}

class _StateLayarPengajuanKetidakhadiran
    extends ConsumerState<LayarPengajuanKetidakhadiran> {
  String _jenisTerpilih = 'Izin';
  final List<String> _daftarJenis = [
    'Izin',
    'SKS (Surat Keterangan Sakit)',
    'Cuti'
  ];
  final TextEditingController _alasanController = TextEditingController();
  File? _lampiran;
  bool _sedangMengirim = false;
  bool _errorAlasan = false;

  DateTime _tglMulai = DateTime.now();
  DateTime _tglSelesai = DateTime.now().add(const Duration(days: 2));

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  void _perbaruiJenis(String? jenisBaru) {
    if (jenisBaru != null) {
      setState(() {
        _jenisTerpilih = jenisBaru;
      });
    }
  }

  int get _jumlahHari {
    return _tglSelesai.difference(_tglMulai).inDays + 1;
  }

  Future<void> _pilihTanggalMulai() async {
    final firstDate = DateTime(2024, 1, 1);
    final initialDate = _tglMulai.isBefore(firstDate) ? firstDate : _tglMulai;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _tglMulai = picked;
        if (_tglSelesai.isBefore(_tglMulai)) {
          _tglSelesai = _tglMulai;
        }
      });
    }
  }

  Future<void> _pilihTanggalSelesai() async {
    final initialDate =
        _tglSelesai.isBefore(_tglMulai) ? _tglMulai : _tglSelesai;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _tglMulai,
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _tglSelesai = picked;
      });
    }
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _konfirmasiKirim() async {
    final alasan = _alasanController.text.trim();
    final isAlasanKosong = alasan.isEmpty;

    if (isAlasanKosong) {
      setState(() {
        _errorAlasan = isAlasanKosong;
      });

      AppNotification.showWarning(
        context,
        'Kolom Alasan wajib diisi terlebih dahulu!',
      );
      return;
    } else {
      setState(() {
        _errorAlasan = false;
      });
    }

    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(LucideIcons.helpCircle, color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Pengajuan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mengirim pengajuan $_jenisTerpilih ini ke Manajemen HR?',
          style: const TextStyle(
              fontSize: 13.5, color: AppColors.onSurfaceVariant),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onSurfaceVariant,
            ),
            child: const Text('Tidak / Batal',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Kirim',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (setuju == true) {
      _kirimPengajuan();
    }
  }

  Future<void> _kirimPengajuan() async {
    final user = ref.read(authProvider).user;
    final idStr = 'CUTI-${DateTime.now().millisecondsSinceEpoch}';
    final rangeTgl =
        '${_formatTanggal(_tglMulai)} - ${_formatTanggal(_tglSelesai)}';
    final alasanText = _alasanController.text.trim().isNotEmpty
        ? _alasanController.text.trim()
        : 'Keperluan $_jenisTerpilih';

    setState(() {
      _sedangMengirim = true;
    });

    final leavePayload = {
      'id': idStr,
      'username': user?.username ?? 'IPM-00002',
      'nama': user?.nama ?? 'Musmaulana',
      'jenis': _jenisTerpilih,
      'tanggal': rangeTgl,
      'alasan': alasanText,
      'status': 'MENUNGGU',
      'createdAt': DateTime.now().toIso8601String(),
      'lampiranPath': _lampiran?.path,
    };

    try {
      final success =
          await ref.read(servicesRepositoryProvider).postLeave(leavePayload);
      if (!success) {
        if (mounted) {
          AppNotification.showError(
              context, 'Gagal mengirim pengajuan cuti ke server.');
        }
        return;
      }

      ref.read(backendDataTriggerProvider.notifier).state++;

      if (mounted) {
        NotificationService().showInstantNotification(
          101,
          'Pengajuan $_jenisTerpilih Terkirim',
          'Pengajuan $_jenisTerpilih Anda berhasil dikirim ke Manajemen HR.',
        );
        AppNotification.showSuccess(
            context, 'Pengajuan cuti/izin berhasil dikirim ke HR!');

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(
            context, 'Gagal: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangMengirim = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Pengajuan Ketidakhadiran',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.fileSpreadsheet,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Form Izin, Cuti & SKS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Isi data ketidakhadiran untuk persetujuan Manajemen HR',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'JENIS & WAKTU KETIDAKHADIRAN',
              icon: LucideIcons.calendarCheck2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Jenis Pengajuan',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),
                  DropdownJenisPengajuan(
                    jenisTerpilih: _jenisTerpilih,
                    daftarJenis: _daftarJenis,
                    onChanged: _perbaruiJenis,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Mulai',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary),
                            ),
                            const SizedBox(height: 6),
                            BidangTanggal(
                              tanggal: _formatTanggal(_tglMulai),
                              onTap: _pilihTanggalMulai,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Selesai',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary),
                            ),
                            const SizedBox(height: 6),
                            BidangTanggal(
                              tanggal: _formatTanggal(_tglSelesai),
                              onTap: _pilihTanggalSelesai,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.clock,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Total Pengajuan: $_jumlahHari Hari',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionCard(
              title: 'ALASAN KETIDAKHADIRAN',
              icon: LucideIcons.messageSquareText,
              hasError: _errorAlasan,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _alasanController,
                    maxLines: 4,
                    onChanged: (val) {
                      if (_errorAlasan && val.trim().isNotEmpty) {
                        setState(() {
                          _errorAlasan = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Tuliskan alasan pengajuan secara jelas dan singkat...',
                      filled: true,
                      fillColor: _errorAlasan
                          ? AppColors.errorBg.withOpacity(0.5)
                          : AppColors.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              _errorAlasan ? AppColors.error : AppColors.border,
                          width: _errorAlasan ? 1.5 : 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              _errorAlasan ? AppColors.error : AppColors.border,
                          width: _errorAlasan ? 1.5 : 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _errorAlasan
                              ? AppColors.error
                              : AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  if (_errorAlasan) ...[
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(LucideIcons.alertCircle,
                            size: 14, color: AppColors.error),
                        SizedBox(width: 6),
                        Text(
                          'Alasan wajib diisi terlebih dahulu',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionCard(
              title: 'LAMPIRAN DOKUMEN PENDUKUNG (OPSIONAL)',
              icon: LucideIcons.paperclip,
              hasError: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UnggahBerkas(
                    onFileSelected: (file) {
                      setState(() {
                        _lampiran = file;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _sedangMengirim ? null : _konfirmasiKirim,
              icon: _sedangMengirim
                  ? const SizedBox.shrink()
                  : const Icon(LucideIcons.send, size: 18),
              label: _sedangMengirim
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'KIRIM PENGAJUAN KE HR',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 15,
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 6,
                shadowColor: AppColors.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    bool hasError = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hasError
            ? AppColors.errorBg.withOpacity(0.2)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasError ? AppColors.error : AppColors.border,
          width: hasError ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: hasError
                ? AppColors.error.withOpacity(0.1)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: hasError ? AppColors.error : AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: hasError ? AppColors.error : AppColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (hasError)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'WAJIB DIISI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
