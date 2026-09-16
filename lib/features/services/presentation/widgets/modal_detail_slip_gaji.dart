import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_notification.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../utils/pdf_payslip_generator.dart';
import 'baris_detail_gaji.dart';


class ModalDetailSlipGaji extends ConsumerWidget {
  final Map<String, dynamic> slipData;

  const ModalDetailSlipGaji({
    super.key,
    required this.slipData,
  });

  String _formatRupiah(num number) {
    final str = number.toInt().toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return 'Rp $str';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final periode = slipData['periode']?.toString() ?? 'Periode Bulan Ini';
    final nama = slipData['nama']?.toString() ?? user?.nama ?? 'Karyawan';
    final username = slipData['username']?.toString() ?? user?.username ?? '-';
    final gajiPokok = slipData['gajiPokok'] ?? 0;
    final tunjangan = slipData['tunjangan'] ?? 0;
    final potongan = slipData['potongan'] ?? 0;
    final totalDiterima = slipData['totalDiterima'] ?? 0;
    final totalJumlahStr = _formatRupiah(totalDiterima);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Detail Slip Gaji',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '$periode • $nama ($username)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          BarisDetailGaji(label: 'Gaji Pokok', nilai: _formatRupiah(gajiPokok)),
          BarisDetailGaji(label: 'Tunjangan Jabatan / Ops', nilai: _formatRupiah(tunjangan)),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          BarisDetailGaji(
            label: 'Potongan BPJS / Pinjaman',
            nilai: '- ${_formatRupiah(potongan)}',
            adalahPotongan: true,
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, thickness: 2),
          const SizedBox(height: 12),
          BarisDetailGaji(
            label: 'Total Gaji Diterima (THP)',
            nilai: totalJumlahStr,
            teksTebal: true,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                String? filePath;
                try {
                  filePath = await PdfPayslipGenerator.simpanKePerangkat(
                    periode: periode,
                    nama: nama,
                    username: username,
                    gajiPokok: gajiPokok,
                    tunjangan: tunjangan,
                    potongan: potongan,
                    totalDiterima: totalDiterima,
                    status: slipData['status']?.toString(),
                  );
                } catch (e) {
                  debugPrint('simpanKePerangkat err: $e');
                }

                try {
                  await PdfPayslipGenerator.unduhAtauCetakPdf(
                    periode: periode,
                    nama: nama,
                    username: username,
                    gajiPokok: gajiPokok,
                    tunjangan: tunjangan,
                    potongan: potongan,
                    totalDiterima: totalDiterima,
                    status: slipData['status']?.toString(),
                  );
                } catch (e) {
                  debugPrint('unduhAtauCetakPdf err: $e');
                }

                if (context.mounted) {
                  AppNotification.showSuccess(
                    context,
                    filePath != null
                        ? 'Berhasil! Slip Gaji tersimpan di: $filePath'
                        : 'Berhasil mengunduh Slip Gaji!',
                  );
                }

                if (filePath != null) {
                  NotificationService().showInstantNotification(
                    201,
                    '📄 Slip Gaji Berhasil Diunduh',
                    'Ketuk notifikasi ini untuk membuka berkas PDF $periode langsung di HP.',
                    payload: filePath,
                  );

                  try {
                    await OpenFilex.open(filePath, type: "application/pdf");
                  } catch (_) {}
                }
              } catch (e) {
                if (context.mounted) {
                  AppNotification.showError(context, 'Gagal mengunduh PDF: ${e.toString().replaceAll('Exception: ', '')}');
                }
              }
            },
            icon: const Icon(LucideIcons.download),
            label: const Text('UNDUH SLIP GAJI', style: TextStyle(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
