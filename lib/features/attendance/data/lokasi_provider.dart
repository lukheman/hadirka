import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model_lokasi_absensi.dart';



final lokasiAbsensiProvider = Provider<List<LokasiAbsensi>>((ref) {
  return const [
    LokasiAbsensi(
      id: 'kantor',
      nama: 'Kantor TJS Dawi-Dawi',
      alamat: 'Jl. Poros Dawi-Dawi, Kec. Pomalaa, Sulawesi Tenggara',
      latitude: -4.178249,
      longitude: 121.610741,
      radius: 80,
      tipe: 'kantor',
      deskripsi: 'Kantor Pusat PT TJS Dawi-Dawi',
    ),
    LokasiAbsensi(
      id: 'site_antam',
      nama: 'Site Antam',
      alamat: 'Kawasan Operasional Tambang Antam Pomalaa',
      latitude: -4.168500,
      longitude: 121.601500,
      radius: 80,
      tipe: 'lapangan',
      deskripsi: 'Titik Presensi Lapangan Site Antam',
    ),
    LokasiAbsensi(
      id: 'site_ipip',
      nama: 'Site IPIP',
      alamat: 'Kawasan Industri Park IPIP Pomalaa',
      latitude: -4.185000,
      longitude: 121.620000,
      radius: 80,
      tipe: 'lapangan',
      deskripsi: 'Titik Presensi Lapangan Site IPIP',
    ),
  ];
});
