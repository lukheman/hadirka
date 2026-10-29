import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../utils/periode_gaji.dart';
import 'baris_detail_gaji.dart';

class ModalDetailSlipGaji extends ConsumerWidget {
  final Map<String, dynamic> slipData;

  const ModalDetailSlipGaji({
    super.key,
    required this.slipData,
  });

  String _formatRupiah(num number) {
    final str = number
        .toInt()
        .toString()
        .replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return 'Rp $str';
  }

  num _asNumber(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final periode = formatPeriodeGaji(slipData['periode']);
    final nama = slipData['nama']?.toString() ?? user?.nama ?? 'Karyawan';
    final username = slipData['username']?.toString() ?? user?.username ?? '-';
    final gajiPokok = _asNumber(slipData['gajiPokok']);
    final metode = (slipData['metodePerhitungan'] ??
            slipData['metodePerhitunganGaji'] ??
            '')
        .toString()
        .toLowerCase();
    final isHarian = metode == 'harian';
    final upahHarian = _asNumber(slipData['upahHarian']);
    final hariKerja = _asNumber(slipData['hariKerja']);
    final potongan = _asNumber(slipData['potongan']);
    final totalDiterima = _asNumber(slipData['totalDiterima']);
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
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '$periode • $nama ($username)',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          BarisDetailGaji(
            label: isHarian ? 'Upah Harian × Hari Kerja' : 'Gaji Pokok Bulanan',
            nilai: isHarian
                ? '${_formatRupiah(upahHarian)} × ${hariKerja.toInt()} = ${_formatRupiah(_asNumber(slipData['pendapatanDasar']) == 0 ? gajiPokok : _asNumber(slipData['pendapatanDasar']))}'
                : _formatRupiah(_asNumber(slipData['gajiPokokBulanan']) == 0
                    ? gajiPokok
                    : _asNumber(slipData['gajiPokokBulanan'])),
          ),
          if (slipData['tipeKaryawan'] != null) ...[
            const SizedBox(height: 8),
            BarisDetailGaji(
              label: 'Tipe Karyawan',
              nilai: slipData['tipeKaryawan'].toString(),
            ),
          ],
          if (slipData['totalPendapatan'] != null) ...[
            const SizedBox(height: 12),
            BarisDetailGaji(
              label: 'Total Pendapatan',
              nilai: _formatRupiah(_asNumber(slipData['totalPendapatan'])),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          BarisDetailGaji(
            label: 'Pinjaman',
            nilai: '- ${_formatRupiah(potongan)}',
            adalahPotongan: true,
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, thickness: 2),
          const SizedBox(height: 12),
          BarisDetailGaji(
            label: 'Total Gaji Diterima',
            nilai: totalJumlahStr,
            teksTebal: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
