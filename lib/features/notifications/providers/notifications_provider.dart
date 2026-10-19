import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/backend/backend_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AppNotifItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final DateTime timestamp;
  final String type;
  final bool isRead;

  AppNotifItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  AppNotifItem copyWith({bool? isRead}) {
    return AppNotifItem(
      id: id,
      title: title,
      message: message,
      time: time,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<AppNotifItem>> {
  final Ref ref;

  NotificationsNotifier(this.ref) : super([]) {
    refreshNotifications();
  }

  Future<void> refreshNotifications() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      state = [];
      return;
    }

    final cleanUser = user.username.trim().toUpperCase();
    final cleanNama = user.nama.trim().toUpperCase();
    final cleanId = user.id.trim().toUpperCase();

    bool isUserAccount(Map<String, dynamic> item) {
      final u = (item['username'] ?? item['username_karyawan'] ?? '')
          .toString()
          .trim()
          .toUpperCase();
      final nik = (item['nik'] ?? item['id_karyawan'] ?? item['id'] ?? '')
          .toString()
          .trim()
          .toUpperCase();
      final nama = (item['nama'] ?? item['nama_karyawan'] ?? '')
          .toString()
          .trim()
          .toUpperCase();

      final matchUsername =
          cleanUser.isNotEmpty && (u == cleanUser || nik == cleanUser);
      final matchId = cleanId.isNotEmpty && (u == cleanId || nik == cleanId);
      final matchNama = cleanNama.isNotEmpty && nama == cleanNama;

      return matchUsername || matchId || matchNama;
    }

    final List<AppNotifItem> list = [];

    try {
      final results = await Future.wait([
        ref.read(attendanceApiServiceProvider).getHistory(''),
        ref.read(servicesRepositoryProvider).getLeave(),
        ref.read(servicesRepositoryProvider).getLoans(),
        ref.read(servicesRepositoryProvider).getPayslips(
              user.nik.trim().isNotEmpty
                  ? user.nik.trim()
                  : (user.username.trim().isNotEmpty
                      ? user.username.trim()
                      : user.id),
            ),
      ]);

      final attendanceLogs = results[0];
      final leaveApps = results[1];
      final loanApps = results[2];
      final payslips = results[3];

      final userLogs =
          attendanceLogs.where((log) => isUserAccount(log)).toList();

      for (var log in userLogs) {
        final tgl = log['tanggal']?.toString() ?? '';
        final rawIn = log['waktuIn']?.toString();
        final rawOut = log['waktuOut']?.toString();

        if (rawIn != null && rawIn.isNotEmpty) {
          list.add(AppNotifItem(
            id: 'in_${log['id_presensi'] ?? tgl}',
            title: 'Presensi Masuk Berhasil',
            message:
                'Presensi masuk tercatat pada jam $rawIn untuk akun ${user.nama}.',
            time: tgl.isNotEmpty ? '$tgl â€¢ $rawIn' : rawIn,
            timestamp: DateTime.tryParse(log['waktu']?.toString() ?? '') ??
                DateTime.now(),
            type: 'attendance',
          ));
        }

        if (rawOut != null && rawOut.isNotEmpty) {
          list.add(AppNotifItem(
            id: 'out_${log['id_presensi'] ?? tgl}',
            title: 'Presensi Keluar Berhasil',
            message:
                'Presensi keluar tercatat pada jam $rawOut. Terima kasih atas kerja keras hari ini!',
            time: tgl.isNotEmpty ? '$tgl â€¢ $rawOut' : rawOut,
            timestamp: DateTime.tryParse(log['waktu']?.toString() ?? '') ??
                DateTime.now(),
            type: 'attendance',
          ));
        }
      }

      final userLeaves =
          leaveApps.where((leave) => isUserAccount(leave)).toList();

      for (var leave in userLeaves) {
        final st = (leave['status'] ?? leave['status_approval'] ?? 'MENUNGGU')
            .toString()
            .toUpperCase();
        final jenis = leave['jenis'] ?? leave['jenis_pengajuan'] ?? 'Cuti';
        final createdAt = leave['createdAt'] ?? leave['tanggal'] ?? '';

        list.add(AppNotifItem(
          id: 'leave_${leave['id'] ?? createdAt}',
          title: 'Pengajuan $jenis: $st',
          message: st == 'DISETUJUI'
              ? 'Pengajuan $jenis Anda (${user.nama}) telah disetujui HRD.'
              : st == 'DITOLAK'
                  ? 'Pengajuan $jenis Anda (${user.nama}) ditolak oleh HRD.'
                  : 'Pengajuan $jenis Anda sedang ditinjau oleh HRD.',
          time: createdAt.toString().split('T').first,
          timestamp: DateTime.tryParse(createdAt.toString()) ?? DateTime.now(),
          type: 'leave',
        ));
      }

      final userLoans = loanApps.where((loan) => isUserAccount(loan)).toList();

      for (var loan in userLoans) {
        final st = (loan['status'] ?? loan['status_approval'] ?? 'MENUNGGU')
            .toString()
            .toUpperCase();
        final createdAt = loan['createdAt'] ?? loan['dibuat_pada'] ?? '';

        list.add(AppNotifItem(
          id: 'loan_${loan['id'] ?? createdAt}',
          title: 'Pengajuan Pinjaman: $st',
          message: st == 'DISETUJUI'
              ? 'Pengajuan pinjaman Anda (${user.nama}) telah disetujui HRD.'
              : st == 'DITOLAK'
                  ? 'Pengajuan pinjaman Anda (${user.nama}) ditolak oleh HRD.'
                  : 'Pengajuan pinjaman Anda sedang diproses oleh HRD.',
          time: createdAt.toString().split('T').first,
          timestamp: DateTime.tryParse(createdAt.toString()) ?? DateTime.now(),
          type: 'loan',
        ));
      }

      final userPayslips =
          payslips.where((slip) => isUserAccount(slip)).toList();

      for (var slip in userPayslips) {
        final periode = slip['periode'] ?? 'Terbaru';
        list.add(AppNotifItem(
          id: 'slip_${slip['id'] ?? periode}',
          title: 'Slip Gaji Diterbitkan',
          message:
              'Slip gaji resmi periode $periode untuk ${user.nama} telah tersedia.',
          time: periode.toString(),
          timestamp: DateTime.now(),
          type: 'payslip',
        ));
      }

      list.add(AppNotifItem(
        id: 'sys_reminder_in',
        title: 'Pengingat Absen Masuk (07:15 WITA)',
        message:
            'Halo ${user.nama}, pastikan presensi masuk dilakukan sebelum 07:30 WITA.',
        time: 'Setiap Hari â€¢ 07:15 WITA',
        timestamp: DateTime.now(),
        type: 'system',
      ));

      list.add(AppNotifItem(
        id: 'sys_reminder_out',
        title: 'Pengingat Absen Keluar (16:00 WITA)',
        message:
            'Halo ${user.nama}, jam kerja telah usai. Jangan lupa presensi keluar.',
        time: 'Setiap Hari â€¢ 16:00 WITA',
        timestamp: DateTime.now(),
        type: 'system',
      ));
    } catch (_) {}

    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = list;
  }

  void markAsRead(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isRead: true) else item
    ];
  }

  void markAllAsRead() {
    state = [for (final item in state) item.copyWith(isRead: true)];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotifItem>>((ref) {
  ref.watch(backendDataTriggerProvider);
  return NotificationsNotifier(ref);
});

final unreadNotifCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.where((n) => !n.isRead).length;
});
