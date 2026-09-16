
class AbsensiConfig {
  
  static const String officeStartTimeStr = '07:30';
  static const String onTimeLimitStr = '08:00';
  static const String officeEndTimeStr = '16:00';
  static const String timezoneName = 'WITA (Asia/Makassar / UTC+8)';

  
  static const int startHour = 7;
  static const int startMinute = 30;

  static const int limitHour = 8;
  static const int limitMinute = 0;

  static const int endHour = 16;
  static const int endMinute = 0;

  static const int utcOffsetHours = 8; 

  
  static DateTime get witaNow {
    return DateTime.now().toUtc().add(const Duration(hours: utcOffsetHours));
  }

  
  static int keTotalMenit(int hour, int minute) {
    return hour * 60 + minute;
  }

  static int get startTotalMinutes => keTotalMenit(startHour, startMinute); 
  static int get limitTotalMinutes => keTotalMenit(limitHour, limitMinute); 
  static int get endTotalMinutes => keTotalMenit(endHour, endMinute);     

  
  
  static int hitungKeterlambatanMenit(DateTime jamMasukWita) {
    final menitMasuk = keTotalMenit(jamMasukWita.hour, jamMasukWita.minute);
    if (menitMasuk <= limitTotalMinutes) {
      return 0;
    }
    return menitMasuk - limitTotalMinutes;
  }

  
  
  static String formatDurasiMenit(int totalMenit) {
    if (totalMenit <= 0) return '0 menit';
    final jam = totalMenit ~/ 60;
    final menit = totalMenit % 60;

    if (jam == 0) {
      return '$menit menit';
    } else if (menit == 0) {
      return '$jam jam';
    } else {
      return '$jam jam $menit menit';
    }
  }

  
  static String formatDurasiRealtime(int totalDetik) {
    if (totalDetik <= 0) return '0 jam 0m 0s';
    final jam = totalDetik ~/ 3600;
    final sisaDetik = totalDetik % 3600;
    final menit = sisaDetik ~/ 60;
    final detik = sisaDetik % 60;

    if (jam == 0) {
      return '${menit}m ${detik}s';
    } else {
      return '${jam}j ${menit}m ${detik}s';
    }
  }

  
  
  static String evaluasiStatusWaktuMasuk(DateTime witaTime) {
    final totalMenit = keTotalMenit(witaTime.hour, witaTime.minute);

    if (totalMenit < startTotalMinutes) {
      return 'belum_dimulai';
    } else if (totalMenit <= limitTotalMinutes) {
      return 'tepat_waktu';
    } else if (totalMenit < endTotalMinutes) {
      return 'terlambat';
    } else {
      return 'jam_operasional_berakhir';
    }
  }

  
  static String formatJamMenit(DateTime dt) {
    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    return '$jam:$menit';
  }

  
  static String formatJamMenitDetik(DateTime dt) {
    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    final detik = dt.second.toString().padLeft(2, '0');
    return '$jam:$menit:$detik';
  }
}
