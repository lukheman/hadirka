class UserAccount {
  final String id;
  final String nik;
  final String username;
  final String nama;
  final String email;
  final String noHp;
  final String role;
  final String jabatan;
  final String departemen;
  final String? token;
  final String? fotoProfil;
  final String? tipeKaryawan;
  final int? idTipeKaryawan;
  final String? metodePerhitunganGaji;
  final String? jamKerjaMulai;
  final String? jamKerjaSelesai;

  const UserAccount({
    required this.id,
    required this.nik,
    required this.username,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.role,
    required this.jabatan,
    required this.departemen,
    this.token,
    this.fotoProfil,
    this.tipeKaryawan,
    this.idTipeKaryawan,
    this.metodePerhitunganGaji,
    this.jamKerjaMulai,
    this.jamKerjaSelesai,
  });

  UserAccount copyWith({
    String? id,
    String? nik,
    String? username,
    String? nama,
    String? email,
    String? noHp,
    String? role,
    String? jabatan,
    String? departemen,
    String? token,
    String? fotoProfil,
    String? tipeKaryawan,
    int? idTipeKaryawan,
    String? metodePerhitunganGaji,
    String? jamKerjaMulai,
    String? jamKerjaSelesai,
  }) {
    return UserAccount(
      id: id ?? this.id,
      nik: nik ?? this.nik,
      username: username ?? this.username,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      role: role ?? this.role,
      jabatan: jabatan ?? this.jabatan,
      departemen: departemen ?? this.departemen,
      token: token ?? this.token,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      tipeKaryawan: tipeKaryawan ?? this.tipeKaryawan,
      idTipeKaryawan: idTipeKaryawan ?? this.idTipeKaryawan,
      metodePerhitunganGaji:
          metodePerhitunganGaji ?? this.metodePerhitunganGaji,
      jamKerjaMulai: jamKerjaMulai ?? this.jamKerjaMulai,
      jamKerjaSelesai: jamKerjaSelesai ?? this.jamKerjaSelesai,
    );
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: (json['id'] ?? json['id_karyawan'] ?? '').toString(),
      nik: (json['nik'] ??
              json['nik_karyawan'] ??
              json['nik_karyawan_internal'] ??
              json['identifier'] ??
              json['username'] ??
              '')
          .toString(),
      username: (json['username'] ??
              json['nik'] ??
              json['nik_karyawan'] ??
              json['identifier'] ??
              '')
          .toString(),
      nama: (json['nama'] ?? json['nama_lengkap'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      noHp: (json['noHp'] ?? json['no_hp'] ?? '').toString(),
      role: (json['role'] ?? 'karyawan').toString(),
      jabatan: (json['jabatan'] ?? '-').toString(),
      departemen: (json['departemen'] ?? '-').toString(),
      token: json['token']?.toString(),
      fotoProfil:
          json['fotoProfil']?.toString() ?? json['foto_profil']?.toString(),
      tipeKaryawan:
          json['tipeKaryawan']?.toString() ?? json['tipe_karyawan']?.toString(),
      idTipeKaryawan:
          _asInt(json['idTipeKaryawan'] ?? json['id_tipe_karyawan']),
      metodePerhitunganGaji: json['metodePerhitunganGaji']?.toString() ??
          json['metode_perhitungan_gaji']?.toString(),
      jamKerjaMulai: json['jamKerjaMulai']?.toString() ??
          json['jam_kerja_mulai']?.toString(),
      jamKerjaSelesai: json['jamKerjaSelesai']?.toString() ??
          json['jam_kerja_selesai']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nik': nik,
      'username': username,
      'nama': nama,
      'email': email,
      'noHp': noHp,
      'role': role,
      'jabatan': jabatan,
      'departemen': departemen,
      'token': token,
      'tipeKaryawan': tipeKaryawan,
      'idTipeKaryawan': idTipeKaryawan,
      'metodePerhitunganGaji': metodePerhitunganGaji,
      'jamKerjaMulai': jamKerjaMulai,
      'jamKerjaSelesai': jamKerjaSelesai,
    };
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    return value is int ? value : int.tryParse(value.toString());
  }
}
