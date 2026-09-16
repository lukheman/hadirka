import 'dart:io';
import 'dart:typed_data';


class ProfilUser {
  final String id;
  final String nik;
  final String nama;
  final String jenisKelamin;
  final String jabatan;
  final String noHp;
  final String departemen;
  final String tanggalMasuk;
  final String statusKepegawaian;
  final String alamat;
  final double gajiPokok;
  final String namaBank;
  final String noRek;
  final String atasNamaRek;
  final File? fotoProfil;
  final Uint8List? fotoProfilBytes;
  final bool notifikasiAktif;

  const ProfilUser({
    required this.id,
    required this.nik,
    required this.nama,
    required this.jenisKelamin,
    required this.noHp,
    required this.jabatan,
    required this.departemen,
    required this.tanggalMasuk,
    required this.statusKepegawaian,
    required this.alamat,
    required this.gajiPokok,
    required this.namaBank,
    required this.noRek,
    required this.atasNamaRek,
    this.fotoProfil,
    this.fotoProfilBytes,
    this.notifikasiAktif = true,
  });

  bool get hasFoto => fotoProfilBytes != null && fotoProfilBytes!.isNotEmpty;

  ProfilUser copyWith({
    String? id,
    String? nik,
    String? nama,
    String? jenisKelamin,
    String? noHp,
    String? jabatan,
    String? departemen,
    String? tanggalMasuk,
    String? statusKepegawaian,
    String? alamat,
    double? gajiPokok,
    String? namaBank,
    String? noRek,
    String? atasNamaRek,
    File? fotoProfil,
    Uint8List? fotoProfilBytes,
    bool clearFoto = false,
    bool? notifikasiAktif,
  }) {
    return ProfilUser(
      id: id ?? this.id,
      nik: nik ?? this.nik,
      nama: nama ?? this.nama,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      noHp: noHp ?? this.noHp,
      jabatan: jabatan ?? this.jabatan,
      departemen: departemen ?? this.departemen,
      tanggalMasuk: tanggalMasuk ?? this.tanggalMasuk,
      statusKepegawaian: statusKepegawaian ?? this.statusKepegawaian,
      alamat: alamat ?? this.alamat,
      gajiPokok: gajiPokok ?? this.gajiPokok,
      namaBank: namaBank ?? this.namaBank,
      noRek: noRek ?? this.noRek,
      atasNamaRek: atasNamaRek ?? this.atasNamaRek,
      fotoProfil: clearFoto ? null : (fotoProfil ?? this.fotoProfil),
      fotoProfilBytes: clearFoto ? null : (fotoProfilBytes ?? this.fotoProfilBytes),
      notifikasiAktif: notifikasiAktif ?? this.notifikasiAktif,
    );
  }
}
