import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/backend/backend_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notification.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/label_input.dart';

class LayarPengajuanPinjaman extends ConsumerStatefulWidget {
  const LayarPengajuanPinjaman({super.key});

  @override
  ConsumerState<LayarPengajuanPinjaman> createState() =>
      _StateLayarPengajuanPinjaman();
}

class _StateLayarPengajuanPinjaman
    extends ConsumerState<LayarPengajuanPinjaman> {
  double _jumlahPinjaman = 0;
  late TextEditingController _nominalController;
  final TextEditingController _alasanController = TextEditingController();
  bool _sedangMengirim = false;
  bool _errorAlasan = false;

  @override
  void initState() {
    super.initState();
    _nominalController = TextEditingController();
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }

  void _perbaruiJumlahDariSlider(double nilaiBaru) {
    setState(() {
      _jumlahPinjaman = nilaiBaru;
      _nominalController.text = _formatNumber(nilaiBaru.toInt());
    });
  }

  void _perbaruiJumlahDariInput(String input) {
    final cleanStr = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanStr.isEmpty) {
      setState(() {
        _jumlahPinjaman = 0;
      });
      return;
    }

    final parsed = double.tryParse(cleanStr) ?? 0;
    final formatted = _formatNumber(parsed.toInt());

    _nominalController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    setState(() {
      _jumlahPinjaman = parsed < 1000000 ? 1000000 : parsed;
    });
  }

  void _tambahNominalPreset(double tambahan) {
    _perbaruiJumlahDariSlider(_jumlahPinjaman + tambahan);
  }

  Future<void> _konfirmasiKirim() async {
    final alasan = _alasanController.text.trim();
    if (_jumlahPinjaman <= 0) {
      AppNotification.showWarning(
        context,
        'Nominal pinjaman wajib diisi terlebih dahulu!',
      );
      return;
    }
    if (alasan.isEmpty) {
      setState(() {
        _errorAlasan = true;
      });
      AppNotification.showWarning(
        context,
        'Kolom Keperluan / Alasan Pinjaman wajib diisi terlebih dahulu!',
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
              'Konfirmasi Pinjaman',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mengajukan pinjaman sebesar Rp ${_formatNumber(_jumlahPinjaman.toInt())} ke HR?',
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
    final idStr = 'LOAN-${DateTime.now().millisecondsSinceEpoch}';
    final alasanText = _alasanController.text.trim().isNotEmpty
        ? _alasanController.text.trim()
        : 'Kebutuhan mendesak';

    setState(() {
      _sedangMengirim = true;
    });

    final loanPayload = {
      'id': idStr,
      'username': user?.username ?? 'IPM-00002',
      'nama': user?.nama ?? 'Musmaulana',
      'nominal': _jumlahPinjaman,
      'alasan': alasanText,
      'status': 'MENUNGGU',
    };

    try {
      final success =
          await ref.read(servicesRepositoryProvider).postLoan(loanPayload);
      if (!success) {
        if (mounted) {
          AppNotification.showError(
              context, 'Gagal mengirim pengajuan pinjaman ke server.');
        }
        return;
      }

      ref.read(backendDataTriggerProvider.notifier).state++;

      if (mounted) {
        NotificationService().showInstantNotification(
          102,
          'Pengajuan Pinjaman Terkirim',
          'Pengajuan pinjaman sebesar Rp ${_formatNumber(_jumlahPinjaman.toInt())} berhasil dikirim ke HR.',
        );
        AppNotification.showSuccess(context,
            'Pengajuan pinjaman sebesar Rp ${_formatNumber(_jumlahPinjaman.toInt())} berhasil dikirim ke HR!');

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
          'Pengajuan Pinjaman',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LabelInput(teks: 'Nominal Pinjaman (Rp)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 18, right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.banknote,
                          color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Rp',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: '0',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: _perbaruiJumlahDariInput,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildNominalChip(
                      '+ 1 Juta', () => _tambahNominalPreset(1000000)),
                  const SizedBox(width: 8),
                  _buildNominalChip(
                      '+ 2.5 Juta', () => _tambahNominalPreset(2500000)),
                  const SizedBox(width: 8),
                  _buildNominalChip(
                      '+ 5 Juta', () => _tambahNominalPreset(5000000)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const LabelInput(teks: 'Keperluan Pinjaman'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _alasanController,
              maxLines: 3,
              onChanged: (val) {
                if (_errorAlasan && val.trim().isNotEmpty) {
                  setState(() {
                    _errorAlasan = false;
                  });
                }
              },
              decoration: InputDecoration(
                hintText:
                    'Jelaskan alasan pengajuan pinjaman secara singkat...',
                filled: true,
                fillColor: _errorAlasan
                    ? AppColors.errorBg.withOpacity(0.5)
                    : AppColors.surfaceContainerLowest,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _errorAlasan ? AppColors.error : AppColors.border,
                    width: _errorAlasan ? 1.5 : 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _errorAlasan ? AppColors.error : AppColors.border,
                    width: _errorAlasan ? 1.5 : 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _errorAlasan ? AppColors.error : AppColors.primary,
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
                    'Keperluan / alasan wajib diisi terlebih dahulu',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: _sedangMengirim ? null : _konfirmasiKirim,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 6,
                shadowColor: AppColors.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _sedangMengirim
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'AJUKAN PINJAMAN',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.8,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNominalChip(String label, VoidCallback onTap,
      {bool isMax = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isMax ? AppColors.primaryFixed : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMax ? AppColors.primary : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isMax ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
