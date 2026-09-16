import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/backend/backend_provider.dart';
import '../../../auth/providers/auth_provider.dart';

final recentActivityProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(backendDataTriggerProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return [];

  final List<Map<String, dynamic>> activities = [];

  try {
    final results = await Future.wait([
      ref.read(attendanceApiServiceProvider).getHistory(''),
      ref.read(servicesRepositoryProvider).getLeave(),
      ref.read(servicesRepositoryProvider).getLoans(),
    ]);

    final attendanceLogs = results[0];
    final leaveApps = results[1];
    final loanApps = results[2];

    final cleanUser = user.username.trim().toUpperCase();
    final cleanNama = user.nama.trim().toUpperCase();

    
    final userLogs = attendanceLogs.where((log) {
      final logU = (log['username'] ?? log['username_karyawan'] ?? '').toString().trim().toUpperCase();
      final logNik = (log['nik'] ?? log['id_karyawan'] ?? '').toString().trim().toUpperCase();
      final logNama = (log['nama'] ?? log['nama_karyawan'] ?? '').toString().trim().toUpperCase();

      return logU == cleanUser ||
          logNik == cleanUser ||
          (cleanNama.isNotEmpty && logNama == cleanNama);
    }).toList();

    for (var log in userLogs) {
      final tgl = log['tanggal']?.toString() ?? '';
      final lokasiNama = (log['lokasiNama'] != null && log['lokasiNama'].toString().isNotEmpty)
          ? log['lokasiNama'].toString()
          : 'Kantor / Site';

      
      final rawIn = log['waktuIn']?.toString();
      if (rawIn != null && rawIn.isNotEmpty) {
        final timeIn = rawIn.replaceAll(' WITA', '').trim();
        DateTime? tsIn;
        try {
          if (log['waktu'] != null) {
            tsIn = DateTime.tryParse(log['waktu'].toString());
          } else if (tgl.isNotEmpty && timeIn.isNotEmpty) {
            tsIn = DateTime.tryParse('${tgl}T$timeIn:00');
          }
        } catch (_) {}

        activities.add({
          'title': 'Presensi Masuk',
          'description': 'Berhasil presensi masuk di $lokasiNama',
          'time': tgl.isNotEmpty ? '$tgl • $rawIn' : rawIn,
          'timestamp': tsIn ?? DateTime.now(),
          'icon': Icons.login,
          'iconBg': AppColors.surfaceContainerHigh,
          'iconColor': AppColors.primary,
        });
      }

      
      final rawOut = log['waktuOut']?.toString();
      if (rawOut != null && rawOut.isNotEmpty) {
        final timeOut = rawOut.replaceAll(' WITA', '').trim();
        DateTime? tsOut;
        try {
          if (tgl.isNotEmpty && timeOut.isNotEmpty) {
            tsOut = DateTime.tryParse('${tgl}T$timeOut:00');
          } else if (log['waktu'] != null) {
            tsOut = DateTime.tryParse(log['waktu'].toString())?.add(const Duration(hours: 8));
          }
        } catch (_) {}

        activities.add({
          'title': 'Presensi Keluar',
          'description': 'Selesai bekerja di $lokasiNama',
          'time': tgl.isNotEmpty ? '$tgl • $rawOut' : rawOut,
          'timestamp': tsOut ?? DateTime.now().add(const Duration(minutes: 1)),
          'icon': Icons.logout,
          'iconBg': AppColors.primaryFixed,
          'iconColor': AppColors.onPrimaryFixed,
        });
      }
    }

    
    final userLeaves = leaveApps.where((leave) {
      final logU = (leave['username'] ?? leave['username_karyawan'] ?? '').toString().trim().toUpperCase();
      final logNik = (leave['id_karyawan'] ?? leave['id'] ?? '').toString().trim().toUpperCase();
      final logNama = (leave['nama'] ?? leave['nama_karyawan'] ?? '').toString().trim().toUpperCase();
      return logU == cleanUser || logNik == cleanUser || (cleanNama.isNotEmpty && logNama == cleanNama);
    }).toList();

    for (var leave in userLeaves) {
      final createdAt = leave['createdAt'] ?? leave['tanggal'] ?? leave['dibuat_pada'] ?? '';
      final st = leave['status'] ?? leave['status_approval'] ?? 'MENUNGGU';
      final jenis = leave['jenis'] ?? leave['jenis_pengajuan'] ?? 'Cuti';
      final alasan = leave['alasan'] ?? leave['alasan_pengajuan'] ?? '';

      activities.add({
        'title': 'Pengajuan $jenis',
        'description': 'Status: $st${alasan.toString().isNotEmpty ? ' - $alasan' : ''}',
        'time': createdAt.toString().split('T').first,
        'timestamp': DateTime.tryParse(createdAt.toString()) ?? DateTime.now(),
        'icon': Icons.event_note,
        'iconBg': Colors.orange.withOpacity(0.15),
        'iconColor': Colors.orange,
      });
    }

    
    final userLoans = loanApps.where((loan) {
      final logU = (loan['username'] ?? loan['username_karyawan'] ?? '').toString().trim().toUpperCase();
      final logNik = (loan['id_karyawan'] ?? loan['id'] ?? '').toString().trim().toUpperCase();
      final logNama = (loan['nama'] ?? loan['nama_karyawan'] ?? '').toString().trim().toUpperCase();
      return logU == cleanUser || logNik == cleanUser || (cleanNama.isNotEmpty && logNama == cleanNama);
    }).toList();

    for (var loan in userLoans) {
      final createdAt = loan['createdAt'] ?? loan['dibuat_pada'] ?? '';
      final st = loan['status'] ?? loan['status_approval'] ?? 'MENUNGGU';
      final rawNominal = loan['nominal'] ?? loan['nominal_pinjaman'] ?? 0;
      final num val = num.tryParse(rawNominal.toString()) ?? 0;
      final strNominal = val.toInt().toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
      final tenor = loan['tenor'] ?? loan['tenor_bulan'] ?? 1;

      activities.add({
        'title': 'Pengajuan Pinjaman',
        'description': 'Status: $st • Rp $strNominal ($tenor bln)',
        'time': createdAt.toString().isNotEmpty ? createdAt.toString().split('T').first : 'Terbaru',
        'timestamp': DateTime.tryParse(createdAt.toString()) ?? DateTime.now(),
        'icon': Icons.account_balance_wallet_outlined,
        'iconBg': AppColors.hrPurpleBg,
        'iconColor': AppColors.hrAccentPurple,
      });
    }
  } catch (_) {}

  activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
  return activities;
});

class BerandaRecentActivity extends ConsumerWidget {
  const BerandaRecentActivity({super.key});

  void _tampilkanSemuaAktivitas(BuildContext context, List<Map<String, dynamic>> activities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Semua Aktivitas Saya',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Riwayat lengkap presensi dan pengajuan',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: activities.length,
                      itemBuilder: (ctx, index) {
                        final activity = activities[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildActivityCard(
                            icon: activity['icon'] as IconData,
                            iconBg: activity['iconBg'] as Color,
                            iconColor: activity['iconColor'] as Color,
                            title: activity['title'] as String,
                            description: activity['description'] as String,
                            time: activity['time'] as String,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivityProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Terakhir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            activitiesAsync.maybeWhen(
              data: (activities) => activities.isNotEmpty
                  ? TextButton(
                      onPressed: () => _tampilkanSemuaAktivitas(context, activities),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Belum ada aktivitas tercatat.',
                    style: TextStyle(color: AppColors.onSurfaceVariant)),
              );
            }
            final homeActivities = activities.take(5).toList();
            return Column(
              children: homeActivities.map((activity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActivityCard(
                    icon: activity['icon'] as IconData,
                    iconBg: activity['iconBg'] as Color,
                    iconColor: activity['iconColor'] as Color,
                    title: activity['title'] as String,
                    description: activity['description'] as String,
                    time: activity['time'] as String,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Gagal memuat aktivitas'),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

