import 'dart:io';


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
    );
  }

  factory DataAbsensi.fromJson(Map<String, dynamic> json) {
    return DataAbsensi(
      id: json['id']?.toString(),
      tipe: json['tipe']?.toString() ?? 'check_in',
      lokasiId: json['lokasiId']?.toString() ?? 'unknown',
      namaLokasi: json['lokasiNama']?.toString() ?? json['namaLokasi']?.toString() ?? 'Lokasi',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      jarak: (json['jarakMeter'] as num?)?.toDouble() ?? (json['jarak'] as num?)?.toDouble() ?? 0.0,
      waktu: json['waktu'] != null ? DateTime.parse(json['waktu'].toString()).toLocal() : DateTime.now(),
      jamMasuk: json['waktuIn'] != null ? _parseTime(json['waktuIn'].toString()) : null,
      jamKeluar: json['waktuOut'] != null ? _parseTime(json['waktuOut'].toString()) : null,
      statusKetepatan: 'hadir',
      keterlambatanMenit: 0,
      durasiKerjaMenit: (json['durasiKerjaMenit'] as num?)?.toInt() ?? 0,
      metodeCheckout: json['metode_checkout']?.toString() ?? json['metodeCheckout']?.toString(),
    );
  }

  static DateTime? _parseTime(String timeStr) {
    try {
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);
      if (match != null) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, int.parse(match.group(1)!), int.parse(match.group(2)!));
      }
      return DateTime.parse(timeStr).toLocal();
    } catch (_) {
      return null;
    }
  }
}
