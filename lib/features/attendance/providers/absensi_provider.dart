import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/absensi_config.dart';
import '../../../core/backend/backend_provider.dart';
import '../data/repositories/attendance_repository.dart';
import '../../services/data/repositories/services_repository.dart';
import '../data/model_lokasi_absensi.dart';
import '../data/model_data_absensi.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/data/model_user.dart';
import '../../../core/services/notification_service.dart';


class AbsensiState {
  final List<LokasiAbsensi> daftarLokasi;
  final Position? posisiSaatIni;
  final LokasiAbsensi? lokasiDipilih;
  final LokasiAbsensi? lokasiTerdekat;
  final double? jarakTerdekat;
  final double? akurasiGps;
  final bool akurasiGpsValid;
  final bool dalamJangkauan;
  final File? fotoSelfie;
  final bool sedangMemproses;
  final bool sudahCheckIn;
  final bool sudahCheckOut;
  final String? pesanError;
  final DataAbsensi? dataCheckIn;
  final DataAbsensi? dataCheckOut;
  final bool lokasiAktif;
  final DateTime? waktuWitaSaatIni;
  final String statusAbsensiKode; 
  final String statusAbsensiLabel;
  final String keteranganJamAbsensi;
  final bool bisaCheckIn;
  final bool bisaCheckOut;
  final int keterlambatanMenit;
  final String keterlambatanTeks;
  final int durasiKerjaMenit;
  final String durasiKerjaTeks;

  const AbsensiState({
    this.daftarLokasi = const [],
    this.posisiSaatIni,
    this.lokasiDipilih,
    this.lokasiTerdekat,
    this.jarakTerdekat,
    this.akurasiGps,
    this.akurasiGpsValid = true,
    this.dalamJangkauan = false,
    this.fotoSelfie,
    this.sedangMemproses = false,
    this.sudahCheckIn = false,
    this.sudahCheckOut = false,
    this.pesanError,
    this.dataCheckIn,
    this.dataCheckOut,
    this.lokasiAktif = false,
    this.waktuWitaSaatIni,
    this.statusAbsensiKode = 'belum_dimulai',
    this.statusAbsensiLabel = 'Memuat...',
    this.keteranganJamAbsensi = '',
    this.bisaCheckIn = false,
    this.bisaCheckOut = false,
    this.keterlambatanMenit = 0,
    this.keterlambatanTeks = '0 menit',
    this.durasiKerjaMenit = 0,
    this.durasiKerjaTeks = '0 menit',
  });

  AbsensiState copyWith({
    List<LokasiAbsensi>? daftarLokasi,
    Position? posisiSaatIni,
    LokasiAbsensi? lokasiDipilih,
    bool clearLokasiDipilih = false,
    LokasiAbsensi? lokasiTerdekat,
    double? jarakTerdekat,
    double? akurasiGps,
    bool? akurasiGpsValid,
    bool? dalamJangkauan,
    File? fotoSelfie,
    bool clearFoto = false,
    bool? sedangMemproses,
    bool? sudahCheckIn,
    bool? sudahCheckOut,
    String? pesanError,
    bool clearError = false,
    DataAbsensi? dataCheckIn,
    DataAbsensi? dataCheckOut,
    bool? lokasiAktif,
    DateTime? waktuWitaSaatIni,
    String? statusAbsensiKode,
    String? statusAbsensiLabel,
    String? keteranganJamAbsensi,
    bool? bisaCheckIn,
    bool? bisaCheckOut,
    int? keterlambatanMenit,
    String? keterlambatanTeks,
    int? durasiKerjaMenit,
    String? durasiKerjaTeks,
  }) {
    return AbsensiState(
      daftarLokasi: daftarLokasi ?? this.daftarLokasi,
      posisiSaatIni: posisiSaatIni ?? this.posisiSaatIni,
      lokasiDipilih: clearLokasiDipilih ? null : (lokasiDipilih ?? this.lokasiDipilih),
      lokasiTerdekat: lokasiTerdekat ?? this.lokasiTerdekat,
      jarakTerdekat: jarakTerdekat ?? this.jarakTerdekat,
      akurasiGps: akurasiGps ?? this.akurasiGps,
      akurasiGpsValid: akurasiGpsValid ?? this.akurasiGpsValid,
      dalamJangkauan: dalamJangkauan ?? this.dalamJangkauan,
      fotoSelfie: clearFoto ? null : (fotoSelfie ?? this.fotoSelfie),
      sedangMemproses: sedangMemproses ?? this.sedangMemproses,
      sudahCheckIn: sudahCheckIn ?? this.sudahCheckIn,
      sudahCheckOut: sudahCheckOut ?? this.sudahCheckOut,
      pesanError: clearError ? null : (pesanError ?? this.pesanError),
      dataCheckIn: dataCheckIn ?? this.dataCheckIn,
      dataCheckOut: dataCheckOut ?? this.dataCheckOut,
      lokasiAktif: lokasiAktif ?? this.lokasiAktif,
      waktuWitaSaatIni: waktuWitaSaatIni ?? this.waktuWitaSaatIni,
      statusAbsensiKode: statusAbsensiKode ?? this.statusAbsensiKode,
      statusAbsensiLabel: statusAbsensiLabel ?? this.statusAbsensiLabel,
      keteranganJamAbsensi: keteranganJamAbsensi ?? this.keteranganJamAbsensi,
      bisaCheckIn: bisaCheckIn ?? this.bisaCheckIn,
      bisaCheckOut: bisaCheckOut ?? this.bisaCheckOut,
      keterlambatanMenit: keterlambatanMenit ?? this.keterlambatanMenit,
      keterlambatanTeks: keterlambatanTeks ?? this.keterlambatanTeks,
      durasiKerjaMenit: durasiKerjaMenit ?? this.durasiKerjaMenit,
      durasiKerjaTeks: durasiKerjaTeks ?? this.durasiKerjaTeks,
    );
  }
}


final absensiProvider =
    StateNotifierProvider<AbsensiNotifier, AbsensiState>((ref) {
  final user = ref.watch(authProvider).user;
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);
  final hrRepo = ref.watch(servicesRepositoryProvider);
  return AbsensiNotifier(ref, const [], user, attendanceRepo, hrRepo);
});

class AbsensiNotifier extends StateNotifier<AbsensiState> {
  // Posisi kasar tetap ditampilkan agar pengguna tahu GPS sedang bekerja.
  // Validasi absensi tetap memakai batas lebih ketat di bawah.
  static const double _maxUsableAccuracyMeters = 10000.0;
  static const double _maxAttendanceAccuracyMeters = 50.0;

  final Ref _ref;
  List<LokasiAbsensi> _daftarLokasi;
  final UserAccount? _user;
  final AttendanceRepository _attendanceRepo;
  final ServicesRepository _hrRepo;
  final ImagePicker _picker = ImagePicker();
  StreamSubscription<Position>? _posisiStream;
  Timer? _retryTimer;
  Timer? _waktuTimer;

  bool _notifikasiCheckOutTerkirim = false;

  AbsensiNotifier(this._ref, this._daftarLokasi, this._user, this._attendanceRepo, this._hrRepo)
      : super(const AbsensiState()) {
    state = state.copyWith(daftarLokasi: _daftarLokasi);
    _initDataHariIni();
    _updateStatusJam();
    _waktuTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateStatusJam();
    });
  }

  Future<void> _initDataHariIni() async {
    if (_user == null) return;
    try {
      final todayLogs = await _attendanceRepo.getHistory(_user!.username);
      final todayStr = AbsensiConfig.witaNow.toIso8601String().substring(0, 10);
      
      final todayData = todayLogs.where((log) {
        final rawTanggal = log.waktu.toIso8601String().substring(0, 10);
        return rawTanggal == todayStr;
      }).toList();
      
      if (todayData.isNotEmpty) {
        final checkInLog = todayData.firstWhere((log) => log.tipe == 'check_in' || log.jamMasuk != null, orElse: () => todayData.first);
        final checkOutLog = todayData.firstWhere((log) => log.tipe == 'check_out' || log.jamKeluar != null, orElse: () => todayData.first);

        final dataIn = checkInLog;
        DataAbsensi? dataOut = (checkOutLog.jamKeluar != null || checkOutLog.tipe == 'check_out') ? checkOutLog : null;

        bool sudahCheckOut = dataOut != null && dataOut.jamKeluar != null;
        int totalMenit = dataOut != null ? dataOut.durasiKerjaMenit : 0;
        if (totalMenit <= 0 && dataIn.jamMasuk != null && dataOut?.jamKeluar != null) {
          totalMenit = dataOut!.jamKeluar!.difference(dataIn.jamMasuk!).inMinutes;
          if (totalMenit < 0) totalMenit = 0;
        }

        if (mounted) {
          state = state.copyWith(
            sudahCheckIn: true,
            dataCheckIn: dataIn,
            sudahCheckOut: sudahCheckOut,
            dataCheckOut: dataOut,
            statusAbsensiKode: sudahCheckOut ? 'sudah_selesai' : 'sedang_bekerja',
            keterlambatanMenit: dataIn.keterlambatanMenit,
            keterlambatanTeks: AbsensiConfig.formatDurasiMenit(dataIn.keterlambatanMenit),
            durasiKerjaMenit: totalMenit,
            durasiKerjaTeks: AbsensiConfig.formatDurasiMenit(totalMenit),
          );
          _updateStatusJam();
        }
      }
    } catch (_) {}
  }



  
  Future<void> muatUlangData() async {
    await _initDataHariIni();
  }

  
  void _updateStatusJam() {
    if (!mounted) return;

    final witaNow = AbsensiConfig.witaNow;
    final statusWaktu = AbsensiConfig.evaluasiStatusWaktuMasuk(witaNow);

    String statusKode = state.statusAbsensiKode;
    String statusLabel = '';
    String ket = '';
    bool bisaCheckIn = false;
    bool bisaCheckOut = false;
    int keterlambatanMenit = state.keterlambatanMenit;
    String keterlambatanTeks = state.keterlambatanTeks;
    int durasiKerjaMenit = state.durasiKerjaMenit;
    String durasiKerjaTeks = state.durasiKerjaTeks;

    if (state.sudahCheckOut) {
      statusKode = 'sudah_selesai';
      statusLabel = 'SUDAH SELESAI';
      ket = 'Absensi dan jam kerja hari ini telah selesai.';
      bisaCheckIn = false;
      bisaCheckOut = false;

      int totalMenit = state.dataCheckOut?.durasiKerjaMenit ?? durasiKerjaMenit;
      if (totalMenit <= 0 && state.dataCheckIn != null && state.dataCheckOut != null) {
        final tIn = state.dataCheckIn!.jamMasuk ?? state.dataCheckIn!.waktu;
        final tOut = state.dataCheckOut!.jamKeluar ?? state.dataCheckOut!.waktu;
        totalMenit = tOut.difference(tIn).inMinutes;
      }
      if (totalMenit < 0) totalMenit = 0;

      durasiKerjaMenit = totalMenit;
      durasiKerjaTeks = AbsensiConfig.formatDurasiMenit(durasiKerjaMenit);
    } else if (state.sudahCheckIn && state.dataCheckIn != null) {
      bisaCheckIn = false;
      bisaCheckOut = true;
      statusKode = 'sedang_bekerja';
      statusLabel = 'SEDANG BEKERJA';

      
      durasiKerjaTeks = 'Menunggu Absen Keluar';

      
      if (witaNow.hour >= 16) {
        ket = 'âš ï¸ PENGINGAT: Jam kerja (16:00 WITA) telah berakhir dan Anda belum Absen Keluar. Segera lakukan Absen Keluar!';
        if (!_notifikasiCheckOutTerkirim) {
          _notifikasiCheckOutTerkirim = true;
          NotificationService().showInstantNotification(
            99,
            'âš ï¸ Pengingat Absen Keluar',
            'Jam operasional telah selesai (16:00 WITA). Anda belum melakukan Absen Keluar hari ini. Segera catat jam kepulangan Anda!',
          );
        }
      } else {
        ket = 'Anda telah melakukan absensi masuk. Durasi jam kerja akan dihitung dan ditampilkan saat Anda melakukan Absen Keluar.';
      }
    } else {
      
      switch (statusWaktu) {
        case 'belum_dimulai':
          statusKode = 'belum_dimulai';
          statusLabel = 'BELUM DIMULAI';
          ket = 'Jam operasional belum dimulai. Absensi masuk & keluar ditutup otomatis.';
          bisaCheckIn = false;
          bisaCheckOut = false;
          break;
        case 'tepat_waktu':
          statusKode = 'tepat_waktu';
          statusLabel = 'TEPAT WAKTU';
          ket = 'Jam operasional sedang berlangsung. Anda masih dalam batas waktu absensi tepat waktu (07:30 - 08:00 WITA).';
          bisaCheckIn = true;
          bisaCheckOut = false;
          keterlambatanMenit = 0;
          keterlambatanTeks = '0 menit';
          break;
        case 'terlambat':
          statusKode = 'terlambat';
          statusLabel = 'TERLAMBAT';
          final kMenit = AbsensiConfig.hitungKeterlambatanMenit(witaNow);
          keterlambatanMenit = kMenit;
          keterlambatanTeks = AbsensiConfig.formatDurasiMenit(kMenit);
          ket = 'Anda melakukan absensi setelah batas waktu 08:00 WITA dan tercatat keterlambatan $keterlambatanTeks.';
          bisaCheckIn = true;
          bisaCheckOut = false;
          break;
        case 'jam_operasional_berakhir':
        default:
          statusKode = 'jam_operasional_berakhir';
          statusLabel = 'JAM OPERASIONAL BERAKHIR';
          ket = 'Jam operasional hari ini (16:00 WITA) telah berakhir. Absensi masuk & keluar ditutup otomatis.';
          bisaCheckIn = false;
          bisaCheckOut = false;
          break;
      }
    }

    state = state.copyWith(
      waktuWitaSaatIni: witaNow,
      statusAbsensiKode: statusKode,
      statusAbsensiLabel: statusLabel,
      keteranganJamAbsensi: ket,
      bisaCheckIn: bisaCheckIn,
      bisaCheckOut: bisaCheckOut,
      keterlambatanMenit: keterlambatanMenit,
      keterlambatanTeks: keterlambatanTeks,
      durasiKerjaMenit: durasiKerjaMenit,
      durasiKerjaTeks: durasiKerjaTeks,
    );
  }

  
  Future<void> mulaiPantauLokasi() async {
    _updateStatusJam();
    _posisiStream?.cancel();
    _posisiStream = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    
    
    try {
      final dataGeofence = await _hrRepo.getGeofence(_user?.username ?? '');
      if (dataGeofence.isNotEmpty) {
        _daftarLokasi = dataGeofence
            .map(LokasiAbsensi.fromJson)
            .where((lokasi) => lokasi.latitude != 0 && lokasi.longitude != 0)
            .toList();

        if (_daftarLokasi.isNotEmpty && mounted) {
          state = state.copyWith(daftarLokasi: _daftarLokasi);
        }
      }
      if (_daftarLokasi.isEmpty && mounted) {
        state = state.copyWith(
          pesanError: 'Site penempatan Anda belum memiliki koordinat GPS. Hubungi HRD untuk melengkapi data lokasi.',
        );
      }
    } catch (_) {}

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        pesanError: 'Layanan lokasi tidak aktif. Aktifkan GPS.',
        lokasiAktif: false,
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          pesanError: 'Izin lokasi ditolak.',
          lokasiAktif: false,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        pesanError: 'Izin lokasi ditolak permanen. Buka pengaturan.',
        lokasiAktif: false,
      );
      return;
    }

    bool lokasiReduced = false;
    try {
      lokasiReduced = await Geolocator.getLocationAccuracy() ==
          LocationAccuracyStatus.reduced;
    } catch (_) {
      // Beberapa versi Android tidak menyediakan status precise/reduced.
      // Tetap lanjutkan GPS; akurasi aktual akan divalidasi dari Position.
    }

    state = state.copyWith(
      lokasiAktif: true,
      clearError: _daftarLokasi.isNotEmpty && !lokasiReduced,
    );
    if (lokasiReduced && mounted) {
      state = state.copyWith(
        pesanError: 'Lokasi masih mode perkiraan. Posisi tetap ditampilkan, tetapi aktifkan Precise/Akurat agar absensi dapat dilakukan.',
      );
    }

    final posisiAkurat = Completer<Position>();
    Position? posisiTerbaik;

    void terimaPosisi(Position posisi) {
      if (!_posisiValid(posisi)) return;
      if (posisiTerbaik == null || posisi.accuracy < posisiTerbaik!.accuracy) {
        posisiTerbaik = posisi;
      }
      _updatePosisi(posisi);
      if (!posisiAkurat.isCompleted && posisi.accuracy <= _maxAttendanceAccuracyMeters) {
        posisiAkurat.complete(posisi);
      }
    }

    // Tampilkan posisi cache lebih dulu agar layar tidak kosong saat GPS
    // membutuhkan waktu mencari fix baru. Posisi cache tidak otomatis membuat
    // absensi valid; validasi akurasi tetap berjalan di bawah.
    try {
      final posisiTerakhir = await Geolocator.getLastKnownPosition();
      if (posisiTerakhir != null) {
        terimaPosisi(posisiTerakhir);
      }
    } catch (_) {}

    _posisiStream = Geolocator.getPositionStream(
      locationSettings: _locationSettings(),
    ).listen(
      terimaPosisi,
      onError: (error) {
        if (!posisiAkurat.isCompleted) {
          posisiAkurat.completeError(error);
        }
      },
    );

    var currentPositionError = false;
    try {
      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings(timeLimit: const Duration(seconds: 12)),
      );
      terimaPosisi(posisi);
    } catch (_) {}

    // Sebagian perangkat Samsung gagal memberi fix lewat Fused Provider saat
    // pertama kali meminta lokasi. Coba Android LocationManager langsung.
    if (Platform.isAndroid && posisiTerbaik == null) {
      try {
        final posisi = await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.best,
            forceLocationManager: true,
            distanceFilter: 0,
            timeLimit: const Duration(seconds: 12),
          ),
        );
        terimaPosisi(posisi);
      } catch (_) {
        currentPositionError = true;
      }
    }

    // Fallback terakhir untuk perangkat yang belum mengunci satelit GPS.
    // Posisi medium hanya untuk menampilkan lokasi; absensi tetap mensyaratkan
    // akurasi maksimal 50 meter.
    if (posisiTerbaik == null) {
      try {
        final posisi = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 0,
            timeLimit: const Duration(seconds: 8),
          ),
        );
        terimaPosisi(posisi);
      } catch (_) {
        currentPositionError = true;
      }
    }

    try {
      await Future.any<Position?>([
        posisiAkurat.future,
        Future<Position?>.delayed(const Duration(seconds: 15), () => null),
      ]);
    } catch (_) {}

    if (mounted && (posisiTerbaik == null || posisiTerbaik!.accuracy > _maxAttendanceAccuracyMeters)) {
      state = state.copyWith(
        pesanError: posisiTerbaik == null && currentPositionError
            ? 'GPS tidak mengirim posisi. Aktifkan Lokasi, izinkan akses saat aplikasi digunakan, matikan penghemat baterai, lalu coba di area terbuka.'
            : 'Akurasi GPS belum cukup (perlu maksimal ±${_maxAttendanceAccuracyMeters.toStringAsFixed(0)}m). Aktifkan Lokasi Akurat/Precise, matikan penghemat baterai, lalu coba di area terbuka.',
      );
    }
  }

  LocationSettings _locationSettings({Duration? timeLimit}) {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
        timeLimit: timeLimit,
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        timeLimit: timeLimit,
      );
    }
    return LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      timeLimit: timeLimit,
    );
  }

  bool _posisiValid(Position posisi) {
    return posisi.latitude.isFinite &&
        posisi.longitude.isFinite &&
        posisi.accuracy.isFinite &&
        posisi.accuracy >= 0 &&
        posisi.accuracy <= _maxUsableAccuracyMeters &&
        posisi.latitude.abs() <= 90 &&
        posisi.longitude.abs() <= 180;
  }

  
  void pilihLokasi(LokasiAbsensi lokasi) {
    state = state.copyWith(lokasiDipilih: lokasi);
    if (state.posisiSaatIni != null) {
      _updatePosisi(state.posisiSaatIni!);
    }
  }

  
  void gantiLokasi() {
    state = state.copyWith(clearLokasiDipilih: true);
  }

  void _updatePosisi(Position posisi) {
    if (!mounted) return;
    if (!_posisiValid(posisi)) return;

    final akurasiLama = state.akurasiGps;
    if (akurasiLama != null &&
        akurasiLama <= _maxAttendanceAccuracyMeters &&
        posisi.accuracy > _maxAttendanceAccuracyMeters) {
      return;
    }
    if (akurasiLama != null &&
        posisi.accuracy > akurasiLama + 20 &&
        state.posisiSaatIni != null) {
      return;
    }

    
    LokasiAbsensi? targetLokasi = state.lokasiDipilih;
    double? jarakTarget;

    if (targetLokasi != null) {
      jarakTarget = Geolocator.distanceBetween(
        posisi.latitude,
        posisi.longitude,
        targetLokasi.latitude,
        targetLokasi.longitude,
      );
    } else {
      for (final lokasi in _daftarLokasi) {
        final jarak = Geolocator.distanceBetween(
          posisi.latitude,
          posisi.longitude,
          lokasi.latitude,
          lokasi.longitude,
        );
        if (jarakTarget == null || jarak < jarakTarget) {
          jarakTarget = jarak;
          targetLokasi = lokasi;
        }
      }
    }

    final bool gpsAkurat = posisi.accuracy <= _maxAttendanceAccuracyMeters;
    final bool dalamRadius = targetLokasi != null &&
        jarakTarget != null &&
        jarakTarget <= targetLokasi.radius &&
        gpsAkurat;

    String? pesanAkurasi;
    if (!gpsAkurat) {
      pesanAkurasi =
          'Akurasi GPS Anda terlalu rendah (Â±${posisi.accuracy.toStringAsFixed(0)}m). Silakan aktifkan lokasi dengan akurasi tinggi.';
    }

    state = state.copyWith(
      posisiSaatIni: posisi,
      lokasiTerdekat: targetLokasi,
      jarakTerdekat: jarakTarget,
      akurasiGps: posisi.accuracy,
      akurasiGpsValid: gpsAkurat,
      dalamJangkauan: dalamRadius,
      pesanError: pesanAkurasi,
      clearError: gpsAkurat,
    );
  }

  void hentikanPantauLokasi() {
    _posisiStream?.cancel();
    _posisiStream = null;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  Future<void> ambilFotoSelfie() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (foto != null) {
        state = state.copyWith(fotoSelfie: File(foto.path), clearError: true);
      }
    } catch (e) {
      state = state.copyWith(pesanError: 'Gagal mengambil foto: $e');
    }
  }

  void hapusFoto() {
    state = state.copyWith(clearFoto: true);
  }

  /// Baca file selfie dan kembalikan sebagai base64 agar tersimpan di server
  /// website (app/uploads/absensi). Mengembalikan null bila gagal/terlalu besar.
  Future<String?> _fotoSelfieBase64() async {
    try {
      final file = state.fotoSelfie;
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty || bytes.length > 2 * 1024 * 1024) return null;
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  
  Future<bool> lakukanAbsensi(String tipe) async {
    _updateStatusJam();

    if (tipe == 'check_in') {
      if (!state.bisaCheckIn) {
        if (state.statusAbsensiKode == 'belum_dimulai') {
          state = state.copyWith(
            pesanError: 'Ditolak: Jam operasional belum dimulai. Absensi dapat dilakukan mulai pukul 07:30 WITA.',
          );
        } else if (state.statusAbsensiKode == 'jam_operasional_berakhir') {
          state = state.copyWith(
            pesanError: 'Ditolak: Jam operasional hari ini (16:00 WITA) telah berakhir. Absensi masuk ditutup.',
          );
        } else {
          state = state.copyWith(
            pesanError: 'Ditolak: Anda sudah melakukan absensi masuk hari ini.',
          );
        }
        return false;
      }
    } else if (tipe == 'check_out') {
      if (!state.bisaCheckOut) {
        if (state.sudahCheckOut) {
          state = state.copyWith(
              pesanError: 'Ditolak: Anda sudah melakukan absensi keluar hari ini.');
        } else if (!state.sudahCheckIn) {
          state = state.copyWith(
              pesanError: 'Gagal Check-Out: Anda belum melakukan Absen Masuk.');
        } else {
          state = state.copyWith(
              pesanError:
                  'Ditolak: Fitur absensi keluar ditutup otomatis di luar jam operasional (07:30 - 16:00 WITA).');
        }
        return false;
      }
    }

    if (state.fotoSelfie == null) {
      state = state.copyWith(pesanError: 'Ambil foto selfie terlebih dahulu.');
      return false;
    }

    if (state.posisiSaatIni == null ||
        state.akurasiGps == null ||
        state.akurasiGps! > _maxAttendanceAccuracyMeters) {
      state = state.copyWith(
        pesanError: 'Akurasi GPS belum cukup. Tunggu sampai akurasi maksimal ±${_maxAttendanceAccuracyMeters.toStringAsFixed(0)}m, lalu coba lagi.',
      );
      return false;
    }

    
    
    if (!state.dalamJangkauan) {
      final maxR = state.lokasiTerdekat?.radius.toStringAsFixed(0) ?? '80';
      state = state.copyWith(
          pesanError: 'Anda tampaknya berada di luar jangkauan (maks ${maxR}m). Data akan dikirim, namun backend bisa saja menolak.');
    }

    state = state.copyWith(sedangMemproses: true, clearError: true);

    try {
      final fotoB64 = await _fotoSelfieBase64();

      final dataAbsensi = await _attendanceRepo.submitAttendance(
        username: _user?.username ?? 'UNKNOWN',
        latitude: state.posisiSaatIni!.latitude,
        longitude: state.posisiSaatIni!.longitude,
        accuracy: state.akurasiGps!,
        tipe: tipe,
        fotoPath: state.fotoSelfie?.path,
        fotoBase64: fotoB64,
      );

      if (tipe == 'check_in') {
        state = state.copyWith(
          sedangMemproses: false,
          sudahCheckIn: true,
          dataCheckIn: dataAbsensi,
          clearFoto: true,
          statusAbsensiKode: 'sedang_bekerja',
          statusAbsensiLabel: 'SEDANG BEKERJA',
          keterlambatanMenit: dataAbsensi.keterlambatanMenit,
          keterlambatanTeks: AbsensiConfig.formatDurasiMenit(dataAbsensi.keterlambatanMenit),
        );

        final statusKehadiran = dataAbsensi.keterlambatanMenit > 0
            ? 'Terlambat (${AbsensiConfig.formatDurasiMenit(dataAbsensi.keterlambatanMenit)})'
            : 'Tepat Waktu';

        NotificationService().showInstantNotification(
          103,
          'Presensi Masuk Berhasil',
          'Presensi Masuk Anda ($statusKehadiran) telah tercatat di sistem.',
        );
      } else {
        state = state.copyWith(
          sedangMemproses: false,
          sudahCheckOut: true,
          dataCheckOut: dataAbsensi,
          clearFoto: true,
          statusAbsensiKode: 'sudah_selesai',
          statusAbsensiLabel: 'SUDAH SELESAI',
          durasiKerjaMenit: dataAbsensi.durasiKerjaMenit,
          durasiKerjaTeks: AbsensiConfig.formatDurasiMenit(dataAbsensi.durasiKerjaMenit),
        );

        NotificationService().showInstantNotification(
          104,
          'Presensi Keluar Berhasil',
          'Presensi Keluar Anda (${AbsensiConfig.formatDurasiMenit(dataAbsensi.durasiKerjaMenit)}) telah tercatat. Terima kasih atas kerja keras hari ini!',
        );
      }

      _updateStatusJam();
      _ref.read(backendDataTriggerProvider.notifier).state++;
      return true;

    } catch (e) {
      state = state.copyWith(
          sedangMemproses: false,
          pesanError: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  @override
  void dispose() {
    _waktuTimer?.cancel();
    hentikanPantauLokasi();
    super.dispose();
  }
}
