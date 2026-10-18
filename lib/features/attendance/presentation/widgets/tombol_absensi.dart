import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/absensi_provider.dart';


class TombolAbsensi extends StatelessWidget {
  final AbsensiState state;
  final Function(String tipe) onProsesAbsensi;

  const TombolAbsensi({
    super.key,
    required this.state,
    required this.onProsesAbsensi,
  });

  @override
  Widget build(BuildContext context) {
    final bisaCheckIn = state.dalamJangkauan &&
        state.fotoSelfie != null &&
        state.bisaCheckIn &&
        !state.sudahCheckIn &&
        !state.sedangMemproses;

    final bisaCheckOut = state.dalamJangkauan &&
        state.fotoSelfie != null &&
        state.bisaCheckOut &&
        !state.sudahCheckOut &&
        !state.sedangMemproses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: state.sudahCheckIn
                ? null
                : (bisaCheckIn ? () => onProsesAbsensi('check_in') : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: state.sudahCheckIn
                  ? AppColors.success
                  : AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.surfaceContainerHigh,
              disabledForegroundColor: AppColors.textTertiary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: bisaCheckIn ? 4 : 0,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: state.sedangMemproses
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        state.sudahCheckIn
                            ? LucideIcons.circleCheck
                            : LucideIcons.logIn,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          state.sudahCheckIn
                              ? 'SUDAH CHECK IN'
                              : 'CHECK IN (ABSEN MASUK)',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),

        
        OutlinedButton(
          onPressed: bisaCheckOut ? () => onProsesAbsensi('check_out') : null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            foregroundColor: state.sudahCheckOut
                ? AppColors.success
                : AppColors.primary,
            side: BorderSide(
              color: state.sudahCheckOut
                  ? AppColors.success
                  : bisaCheckOut
                      ? AppColors.primary
                      : AppColors.border,
              width: 2,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.sudahCheckOut
                    ? LucideIcons.circleCheck
                    : LucideIcons.logOut,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  state.sudahCheckOut
                      ? 'SUDAH CHECK OUT'
                      : 'CHECK OUT (ABSEN KELUAR)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),

        
        if (state.statusAbsensiKode == 'belum_dimulai' && !state.sudahCheckOut) ...[
          const SizedBox(height: 12),
          _buildHelperMessage(
            'Jam operasional belum dimulai (07:30 WITA). Fitur absen masuk & keluar ditutup otomatis.',
            LucideIcons.clock,
            AppColors.warning,
          ),
        ],
        if (state.statusAbsensiKode == 'jam_operasional_berakhir' && !state.sudahCheckOut) ...[
          const SizedBox(height: 12),
          _buildHelperMessage(
            'Jam operasional hari ini (16:00 WITA) telah berakhir. Fitur absen masuk & keluar ditutup otomatis.',
            LucideIcons.timerOff,
            AppColors.error,
          ),
        ],
        if ((state.bisaCheckIn || state.bisaCheckOut) &&
            !state.dalamJangkauan &&
            state.lokasiAktif) ...[
          const SizedBox(height: 12),
          _buildHelperMessage(
            state.akurasiGps != null && !state.akurasiGpsValid
                ? 'Akurasi GPS belum cukup (±${state.akurasiGps!.toStringAsFixed(0)}m). Aktifkan Precise/Lokasi Akurat dan pindah ke area terbuka.'
                : 'Dekatkan posisi Anda ke lokasi absensi (maks ${(state.lokasiDipilih ?? state.lokasiTerdekat)?.radius.toStringAsFixed(0) ?? "-"} meter)',
            LucideIcons.mapPin,
            AppColors.warning,
          ),
        ],
        if ((state.bisaCheckIn || state.bisaCheckOut) &&
            state.dalamJangkauan &&
            state.fotoSelfie == null &&
            !state.sudahCheckOut) ...[
          const SizedBox(height: 12),
          _buildHelperMessage(
            state.sudahCheckIn
                ? 'Ambil foto selfie terlebih dahulu untuk Check Out'
                : 'Ambil foto selfie terlebih dahulu untuk Check In',
            LucideIcons.camera,
            AppColors.secondary,
          ),
        ],
      ],
    );
  }

  Widget _buildHelperMessage(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
