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
}
