class LokasiAbsensi {
  final String id;
  final String nama;
  final String alamat;
  final double latitude;
  final double longitude;
  final double radius; 
  final String tipe; 
  final String? deskripsi;

  const LokasiAbsensi({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    this.radius = 80,
    this.tipe = 'kantor',
    this.deskripsi,
  });

  factory LokasiAbsensi.fromJson(Map<String, dynamic> json) {
    return LokasiAbsensi(
      id: json['id']?.toString() ?? json['kode']?.toString() ?? 'unknown',
      nama: json['nama']?.toString() ?? 'Lokasi Absensi',
      alamat: json['alamat']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      radius: (json['radius'] as num?)?.toDouble() ?? 80,
      tipe: json['tipe']?.toString() ?? 'kantor',
      deskripsi: json['deskripsi']?.toString(),
    );
  }
}
