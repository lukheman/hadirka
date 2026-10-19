import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../data/models/item_layanan_model.dart';
import 'widgets/kategori_layanan.dart';

class LayarLayanan extends StatelessWidget {
  const LayarLayanan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Layanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 1200,
        child: ListView(
          padding:
              const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 100),
          children: [
            KategoriLayanan(
              judulKategori: 'PENGELOLAAN WAKTU',
              itemLayanan: [
                ItemLayananModel(
                  judul: 'Pengajuan Ketidakhadiran',
                  subjudul: 'Izin, Cuti, SKS',
                  ikon: LucideIcons.calendarClock,
                  rute: '/services/leave',
                  warnaIkon: AppColors.primary,
                  latarIkon: AppColors.surfaceContainer,
                ),
              ],
            ),
            const SizedBox(height: 32),
            KategoriLayanan(
              judulKategori: 'KEUANGAN & BENEFIT',
              itemLayanan: [
                ItemLayananModel(
                  judul: 'Slip Gaji',
                  subjudul: 'Lihat riwayat slip gaji bulanan',
                  ikon: LucideIcons.receipt,
                  rute: '/services/payslip',
                  warnaIkon: AppColors.success,
                  latarIkon: AppColors.successBg,
                ),
                ItemLayananModel(
                  judul: 'Pengajuan Pinjaman',
                  subjudul: 'Pinjaman karyawan & status',
                  ikon: LucideIcons.banknote,
                  rute: '/services/loan',
                  warnaIkon: AppColors.warning,
                  latarIkon: AppColors.warningBg,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
