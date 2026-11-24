import 'dart:io';

import '../../../core/constants/absensi_config.dart';

class DataAbsensi {
  final String? id;
  final String tipe;
  final String lokasiId;
  final String namaLokasi;
  final double latitude;
  final double longitude;
  final double jarak;
  final File? foto;
  final DateTime waktu;
  final DateTime? jamMasuk;
  final DateTime? jamKeluar;
  final String statusKetepatan;
  final int keterlambatanMenit;
  final int durasiKerjaMenit;
  final String? metodeCheckout;
  final String? jamKerjaMulai;
  final String? jamKerjaSelesai;
  const DataAbsensi({
    this.id,
    required this.tipe,
    required this.lokasiId,
    required this.namaLokasi,
    required this.latitude,
    required this.longitude,
    required this.jarak,
    this.foto,
    required this.waktu,
    this.jamMasuk,
    this.jamKeluar,
    this.statusKetepatan = 'tepat_waktu',
    this.keterlambatanMenit = 0,
    this.durasiKerjaMenit = 0,
    this.metodeCheckout,
    this.jamKerjaMulai,
    this.jamKerjaSelesai,
  });

  DataAbsensi copyWith({
    String? id,
    String? tipe,
    String? lokasiId,
    String? namaLokasi,
    double? latitude,
    double? longitude,
    double? jarak,
    File? foto,
    DateTime? waktu,
    DateTime? jamMasuk,
    DateTime? jamKeluar,
    String? statusKetepatan,
    int? keterlambatanMenit,
    int? durasiKerjaMenit,
    String? metodeCheckout,
    String? jamKerjaMulai,
    String? jamKerjaSelesai,
  }) {
    return DataAbsensi(
      id: id ?? this.id,
      tipe: tipe ?? this.tipe,
      lokasiId: lokasiId ?? this.lokasiId,
      namaLokasi: namaLokasi ?? this.namaLokasi,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      jarak: jarak ?? this.jarak,
      foto: foto ?? this.foto,
      waktu: waktu ?? this.waktu,
      jamMasuk: jamMasuk ?? this.jamMasuk,
      jamKeluar: jamKeluar ?? this.jamKeluar,
      statusKetepatan: statusKetepatan ?? this.statusKetepatan,
      keterlambatanMenit: keterlambatanMenit ?? this.keterlambatanMenit,
      durasiKerjaMenit: durasiKerjaMenit ?? this.durasiKerjaMenit,
      metodeCheckout: metodeCheckout ?? this.metodeCheckout,
      jamKerjaMulai: jamKerjaMulai ?? this.jamKerjaMulai,
      jamKerjaSelesai: jamKerjaSelesai ?? this.jamKerjaSelesai,
    );
  }

  factory DataAbsensi.fromJson(Map<String, dynamic> json) {
    final waktu = json['waktu'] != null
        ? DateTime.parse(json['waktu'].toString()).toLocal()
        : DateTime.now();
    final jamMasuk =
        json['waktuIn'] != null ? _parseTime(json['waktuIn'].toString()) : null;
    final jamKeluar = json['waktuOut'] != null
        ? _parseTime(json['waktuOut'].toString())
        : null;

    // Server dapat mengirim keterlambatan eksplisit; bila tidak ada, hitung
    // dari jam masuk agar status "Terlambat"/"Tepat Waktu" tetap akurat.
    final lateRaw = json['keterlambatanMenit'] ?? json['keterlambatan_menit'];
    var keterlambatanMenit = (lateRaw as num?)?.toInt();
    if (keterlambatanMenit == null || keterlambatanMenit < 0) {
      keterlambatanMenit = AbsensiConfig.hitungKeterlambatanAbsensi(
        jamMasuk: jamMasuk,
        waktuPresensi: waktu,
      );
    }

    final statusRaw = (json['statusKehadiran'] ??
            json['status_kehadiran'] ??
            json['statusKetepatan'] ??
            json['status_ketepatan'])
        ?.toString()
        .toLowerCase();
    final tepatWaktuRaw = json['isTepatWaktu'] ?? json['is_tepat_waktu'];

    var statusKetepatan = keterlambatanMenit > 0 ? 'terlambat' : 'tepat_waktu';
    if (statusRaw != null && statusRaw.isNotEmpty) {
      if (statusRaw.contains('terlambat')) {
        statusKetepatan = 'terlambat';
      } else if (statusRaw.contains('tepat') || statusRaw.contains('hadir')) {
        statusKetepatan = keterlambatanMenit > 0 ? 'terlambat' : 'tepat_waktu';
      }
    }
    if (tepatWaktuRaw is bool && !tepatWaktuRaw) {
      statusKetepatan = 'terlambat';
    }

    return DataAbsensi(
      id: json['id']?.toString(),
      tipe: json['tipe']?.toString() ?? 'check_in',
      lokasiId: json['lokasiId']?.toString() ?? 'unknown',
      namaLokasi: json['lokasiNama']?.toString() ??
          json['namaLokasi']?.toString() ??
          'Lokasi',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      jarak: (json['jarakMeter'] as num?)?.toDouble() ??
          (json['jarak'] as num?)?.toDouble() ??
          0.0,
      waktu: waktu,
      jamMasuk: jamMasuk,
      jamKeluar: jamKeluar,
      statusKetepatan: statusKetepatan,
      keterlambatanMenit: keterlambatanMenit,
      durasiKerjaMenit: (json['durasiKerjaMenit'] as num?)?.toInt() ?? 0,
      metodeCheckout: json['metode_checkout']?.toString() ??
          json['metodeCheckout']?.toString(),
      jamKerjaMulai: json['jamKerjaMulai']?.toString() ??
          json['jam_kerja_mulai']?.toString(),
      jamKerjaSelesai: json['jamKerjaSelesai']?.toString() ??
          json['jam_kerja_selesai']?.toString(),
    );
  }

  static DateTime? _parseTime(String timeStr) {
    try {
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);
      if (match != null) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day,
            int.parse(match.group(1)!), int.parse(match.group(2)!));
      }
      return DateTime.parse(timeStr).toLocal();
    } catch (_) {
      return null;
    }
  }
}
