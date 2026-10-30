import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/absensi_config.dart';
import '../../../core/backend/backend_provider.dart';
import '../data/repositories/attendance_repository.dart';
import '../../services/data/repositories/services_repository.dart';
import '../data/model_lokasi_absensi.dart';
import '../data/model_data_absensi.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/data/model_user.dart';
import '../../../core/services/notification_service.dart';
import '../services/timemark_service.dart';

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
      lokasiDipilih:
          clearLokasiDipilih ? null : (lokasiDipilih ?? this.lokasiDipilih),
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
  StreamSubscription<Position>? _posisiStream;
  Timer? _retryTimer;
  Timer? _waktuTimer;
  Timer? _keluarLokasiTimer;

  bool _notifikasiCheckOutTerkirim = false;
  bool _lokasiPresisiAktif = true;

  AbsensiNotifier(this._ref, this._daftarLokasi, this._user,
      this._attendanceRepo, this._hrRepo)
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
        final checkInLog = todayData.firstWhere(
            (log) => log.tipe == 'check_in' || log.jamMasuk != null,
            orElse: () => todayData.first);
        final checkOutLog = todayData.firstWhere(
            (log) => log.tipe == 'check_out' || log.jamKeluar != null,
            orElse: () => todayData.first);

        final dataIn = checkInLog;
        DataAbsensi? dataOut =
            (checkOutLog.jamKeluar != null || checkOutLog.tipe == 'check_out')
                ? checkOutLog
                : null;

        bool sudahCheckOut = dataOut != null && dataOut.jamKeluar != null;
        int totalMenit = dataOut != null ? dataOut.durasiKerjaMenit : 0;
        if (totalMenit <= 0 &&
            dataIn.jamMasuk != null &&
            dataOut?.jamKeluar != null) {
          totalMenit =
              dataOut!.jamKeluar!.difference(dataIn.jamMasuk!).inMinutes;
          if (totalMenit < 0) totalMenit = 0;
        }

        if (mounted) {
          state = state.copyWith(
            sudahCheckIn: true,
            dataCheckIn: dataIn,
            sudahCheckOut: sudahCheckOut,
            dataCheckOut: dataOut,
            statusAbsensiKode:
                sudahCheckOut ? 'sudah_selesai' : 'sedang_bekerja',
            keterlambatanMenit: 0,
            keterlambatanTeks: '0 menit',
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
      if (totalMenit <= 0 &&
          state.dataCheckIn != null &&
          state.dataCheckOut != null) {
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
        ket =
            'âš ï¸ PENGINGAT: Jam kerja (16:00 WITA) telah berakhir dan Anda belum Absen Keluar. Segera lakukan Absen Keluar!';
        if (!_notifikasiCheckOutTerkirim) {
          _notifikasiCheckOutTerkirim = true;
          NotificationService().showInstantNotification(
            99,
            'âš ï¸ Pengingat Absen Keluar',
            'Jam operasional telah selesai (16:00 WITA). Anda belum melakukan Absen Keluar hari ini. Segera catat jam kepulangan Anda!',
          );
        }
      } else {
        ket = '';
      }
    } else {
      statusKode = 'tepat_waktu';
      statusLabel = 'SIAP ABSEN';
      ket = '';
      bisaCheckIn = true;
      bisaCheckOut = false;
      keterlambatanMenit = 0;
      keterlambatanTeks = '0 menit';
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
    if (kDebugMode) {
      debugPrint(
          'GPS service enabled: ${await Geolocator.isLocationServiceEnabled()}');
    }
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
          pesanError:
              'Site penempatan Anda belum memiliki koordinat GPS. Hubungi HRD untuk melengkapi data lokasi.',
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

    if (kDebugMode) {
      debugPrint('GPS permission: $permission');
    }

    bool lokasiReduced = false;
    try {
      lokasiReduced = await Geolocator.getLocationAccuracy() ==
          LocationAccuracyStatus.reduced;

      if (lokasiReduced && Platform.isIOS) {
        try {
          final status = await Geolocator.requestTemporaryFullAccuracy(
            purposeKey: 'AbsensiPresisi',
          );
          lokasiReduced = status == LocationAccuracyStatus.reduced;
        } catch (_) {
          // User can still enable Precise manually from system settings.
        }
      }
    } catch (_) {
      // Beberapa versi Android tidak menyediakan status precise/reduced.
      // Akurasi aktual tetap divalidasi dari Position.
    }

    if (kDebugMode) {
      debugPrint('GPS precise: ${!lokasiReduced}');
    }

    state = state.copyWith(
      lokasiAktif: true,
      clearError: _daftarLokasi.isNotEmpty && !lokasiReduced,
    );
    _lokasiPresisiAktif = !lokasiReduced;
    if (lokasiReduced && mounted) {
      state = state.copyWith(
        pesanError:
            'Lokasi masih mode perkiraan. Posisi tetap ditampilkan, tetapi aktifkan Precise/Akurat agar absensi dapat dilakukan.',
      );
    }

    final posisiAkurat = Completer<void>();
    Position? posisiTerbaik;
    var streamError = false;

    void terimaPosisi(Position posisi, {bool isLive = true}) {
      if (posisi.isMocked) {
        if (mounted) {
          state = state.copyWith(
            akurasiGps: _maxUsableAccuracyMeters + 1,
            akurasiGpsValid: false,
            dalamJangkauan: false,
            pesanError:
                'Lokasi tiruan terdeteksi. Matikan Mock location sebelum absensi.',
          );
        }
        return;
      }
      if (!_posisiValid(posisi)) return;
      if (isLive &&
          (posisiTerbaik == null ||
              posisi.accuracy < posisiTerbaik!.accuracy)) {
        posisiTerbaik = posisi;
      }
      _updatePosisi(posisi, isLive: isLive);
      if (isLive &&
          !posisiAkurat.isCompleted &&
          posisi.accuracy <= _maxAttendanceAccuracyMeters) {
        posisiAkurat.complete();
      }
    }

    _posisiStream = Geolocator.getPositionStream(
      locationSettings: _locationSettings(),
    ).listen(
      (posisi) {
        if (kDebugMode) {
          debugPrint(
            'GPS live: lat=${posisi.latitude}, lng=${posisi.longitude}, '
            'accuracy=${posisi.accuracy}m, mocked=${posisi.isMocked}',
          );
        }
        terimaPosisi(posisi);
      },
      onError: (error) {
        if (!posisiAkurat.isCompleted) {
          streamError = true;
          if (kDebugMode) debugPrint('GPS stream error: $error');
        }
      },
    );

    try {
      await Future.any<void>([
        posisiAkurat.future,
        Future<void>.delayed(const Duration(seconds: 30)),
      ]);
    } catch (_) {}

    if (mounted &&
        (posisiTerbaik == null ||
            posisiTerbaik!.accuracy > _maxAttendanceAccuracyMeters)) {
      state = state.copyWith(
        pesanError: streamError || posisiTerbaik == null
            ? 'GPS belum mengirim posisi presisi. Aktifkan Precise/Lokasi Akurat, matikan penghemat baterai, lalu coba di area terbuka.'
            : 'Akurasi GPS belum cukup setelah 30 detik (±${posisiTerbaik!.accuracy.toStringAsFixed(0)}m). Pindah ke area terbuka lalu muat ulang GPS.',
      );
    }
  }

  LocationSettings _locationSettings({Duration? timeLimit}) {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        forceLocationManager: true,
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
        !posisi.isMocked &&
        posisi.accuracy >= 0 &&
        posisi.accuracy <= _maxUsableAccuracyMeters &&
        posisi.latitude.abs() <= 90 &&
        posisi.longitude.abs() <= 180;
  }

  void pilihLokasi(LokasiAbsensi lokasi) {
    state = state.copyWith(lokasiDipilih: lokasi);
    if (state.posisiSaatIni != null) {
      _updatePosisi(
        state.posisiSaatIni!,
        isLive: state.akurasiGpsValid,
      );
    }
  }

  void gantiLokasi() {
    state = state.copyWith(clearLokasiDipilih: true);
  }

  void _updatePosisi(Position posisi, {bool isLive = true}) {
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

    final bool gpsAkurat = isLive &&
        _lokasiPresisiAktif &&
        posisi.accuracy <= _maxAttendanceAccuracyMeters;
    final bool dalamRadius = targetLokasi != null &&
        jarakTarget != null &&
        jarakTarget <= targetLokasi.radius &&
        gpsAkurat;

    String? pesanAkurasi;
    if (!_lokasiPresisiAktif) {
      pesanAkurasi =
          'Lokasi masih Approximate/Perkiraan (±${posisi.accuracy.toStringAsFixed(0)}m). Buka Pengaturan Lokasi, aktifkan "Gunakan lokasi akurat/Precise", lalu muat ulang GPS.';
    } else if (!gpsAkurat) {
      pesanAkurasi =
          'Akurasi GPS Anda terlalu rendah (±${posisi.accuracy.toStringAsFixed(0)}m). Aktifkan Precise/Lokasi Akurat dan coba di area terbuka.';
    }

    state = state.copyWith(
      posisiSaatIni: posisi,
      lokasiTerdekat: targetLokasi,
      jarakTerdekat: jarakTarget,
      akurasiGps: posisi.accuracy,
      akurasiGpsValid: gpsAkurat,
      dalamJangkauan: dalamRadius,
      pesanError: pesanAkurasi,
      clearError: gpsAkurat && _lokasiPresisiAktif,
    );

    _pantauKeluarLokasi(targetLokasi, jarakTarget, gpsAkurat);
  }

  void _pantauKeluarLokasi(
      LokasiAbsensi? lokasi, double? jarak, bool gpsAkurat) {
    if (!state.sudahCheckIn || state.sudahCheckOut || lokasi == null ||
        jarak == null || !gpsAkurat || jarak <= 1000) {
      _keluarLokasiTimer?.cancel();
      _keluarLokasiTimer = null;
      return;
    }
    if (_keluarLokasiTimer != null) return;
    _keluarLokasiTimer = Timer(const Duration(hours: 1), () {
      _keluarLokasiTimer = null;
      _checkoutOtomatis();
    });
  }

  Future<void> _checkoutOtomatis() async {
    if (!mounted || !state.sudahCheckIn || state.sudahCheckOut ||
        state.posisiSaatIni == null || state.akurasiGps == null) return;
    try {
      final data = await _attendanceRepo.submitAttendance(
        username: _user?.username ?? 'UNKNOWN',
        latitude: state.posisiSaatIni!.latitude,
        longitude: state.posisiSaatIni!.longitude,
        accuracy: state.akurasiGps!,
        tipe: 'check_out',
        metodeCheckout: 'otomatis',
      );
      state = state.copyWith(
        sudahCheckOut: true,
        dataCheckOut: data,
        statusAbsensiKode: 'sudah_selesai',
        statusAbsensiLabel: 'SUDAH SELESAI',
        durasiKerjaMenit: data.durasiKerjaMenit,
        durasiKerjaTeks: AbsensiConfig.formatDurasiMenit(data.durasiKerjaMenit),
      );
      NotificationService().showInstantNotification(
        105,
        'Presensi Keluar Otomatis',
        'Anda berada di luar lokasi kerja lebih dari 1 km selama 1 jam.',
      );
    } catch (_) {}
  }

  void hentikanPantauLokasi() {
    _posisiStream?.cancel();
    _posisiStream = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _keluarLokasiTimer?.cancel();
    _keluarLokasiTimer = null;
  }

  Future<void> simpanFotoSelfie(File foto) async {
    try {
      final target = state.lokasiDipilih ?? state.lokasiTerdekat;
      final fotoTimemark = await TimemarkService.tempelTimemark(
        foto: foto,
        waktu: AbsensiConfig.witaNow,
        namaLokasi: target?.nama ?? 'Lokasi Absensi',
        latitude: state.posisiSaatIni?.latitude,
        longitude: state.posisiSaatIni?.longitude,
        akurasi: state.akurasiGps,
      );
      state = state.copyWith(fotoSelfie: fotoTimemark, clearError: true);
    } catch (e) {
      state = state.copyWith(pesanError: 'Gagal membuat foto timemark: $e');
    }
  }

  void hapusFoto() {
    state = state.copyWith(clearFoto: true);
  }

  /// Baca file selfie dan kembalikan sebagai base64 agar tersimpan di server
  /// website (app/uploads/absensi).
  Future<String> _fotoSelfieBase64() async {
    try {
      final file = state.fotoSelfie;
      if (file == null) {
        throw StateError('Foto selfie belum tersedia. Ambil foto ulang.');
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw StateError('Foto selfie kosong. Ambil foto ulang.');
      }
      if (bytes.length > 7 * 1024 * 1024) {
        throw StateError('Ukuran foto terlalu besar. Ambil foto ulang.');
      }
      return base64Encode(bytes);
    } on StateError {
      rethrow;
    } catch (error) {
      throw StateError('Foto tidak dapat dibaca: $error');
    }
  }

  Future<bool> lakukanAbsensi(String tipe) async {
    _updateStatusJam();

    if (tipe == 'check_in') {
      if (!state.bisaCheckIn) {
        state = state.copyWith(
          pesanError: 'Ditolak: Anda sudah melakukan absensi masuk hari ini.',
        );
        return false;
      }
    } else if (tipe == 'check_out') {
      if (!state.bisaCheckOut) {
        if (state.sudahCheckOut) {
          state = state.copyWith(
              pesanError:
                  'Ditolak: Anda sudah melakukan absensi keluar hari ini.');
        } else if (!state.sudahCheckIn) {
          state = state.copyWith(
              pesanError: 'Gagal absen keluar: Anda belum melakukan absen masuk.');
        } else {
          state = state.copyWith(
              pesanError: 'Gagal absen keluar: status absensi belum siap.');
        }
        return false;
      }
    }

    if (state.fotoSelfie == null) {
      state = state.copyWith(pesanError: 'Ambil foto selfie terlebih dahulu.');
      return false;
    }

    if (!_lokasiPresisiAktif) {
      state = state.copyWith(
        pesanError:
            'Absensi membutuhkan lokasi presisi. Pilih “Precise” saat diminta atau aktifkan “Use precise location” di pengaturan aplikasi.',
      );
      return false;
    }

    if (state.posisiSaatIni == null ||
        state.akurasiGps == null ||
        state.akurasiGps! > _maxAttendanceAccuracyMeters) {
      state = state.copyWith(
        pesanError:
            'Akurasi GPS belum cukup. Tunggu sampai akurasi maksimal ±${_maxAttendanceAccuracyMeters.toStringAsFixed(0)}m, lalu coba lagi.',
      );
      return false;
    }

    if (!state.dalamJangkauan) {
      final maxR = state.lokasiTerdekat?.radius.toStringAsFixed(0) ?? '80';
      state = state.copyWith(
          pesanError:
              'Anda tampaknya berada di luar jangkauan (maks ${maxR}m). Data akan dikirim, namun backend bisa saja menolak.');
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
        // Path lokal Android tidak dapat dibaca server. Foto dikirim melalui
        // base64 dan server membuat path upload-nya sendiri.
        fotoPath: null,
        fotoBase64: fotoB64,
        metodeCheckout: tipe == 'check_out' ? 'manual' : null,
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
          keterlambatanTeks:
              AbsensiConfig.formatDurasiMenit(dataAbsensi.keterlambatanMenit),
        );

        NotificationService().showInstantNotification(
          103,
          'Presensi Masuk Berhasil',
          'Presensi Masuk Anda telah tercatat di sistem.',
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
          durasiKerjaTeks:
              AbsensiConfig.formatDurasiMenit(dataAbsensi.durasiKerjaMenit),
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
