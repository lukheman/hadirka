import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/backend/backend_provider.dart';
import '../../../auth/providers/auth_provider.dart';

final calendarDataProvider =
    FutureProvider<Map<String, Map<String, dynamic>>>((ref) async {
  ref.watch(backendDataTriggerProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return {};

  final Map<String, Map<String, dynamic>> dateMap = {};

  try {
    final results = await Future.wait([
      ref.read(attendanceApiServiceProvider).getHistory(''),
      ref.read(servicesRepositoryProvider).getLeave(),
    ]);

    final attendanceLogs = results[0];
    final leaveApps = results[1];

    final cleanUser = user.username.trim().toUpperCase();

    final userLogs = attendanceLogs.where((log) {
      final u =
          (log['username'] ?? log['id'] ?? '').toString().trim().toUpperCase();
      return u == cleanUser;
    }).toList();

    for (var log in userLogs) {
      final tglStr = log['tanggal']?.toString() ?? '';
      if (tglStr.isNotEmpty) {
        final cleanDate =
            tglStr.length >= 10 ? tglStr.substring(0, 10) : tglStr;
        dateMap[cleanDate] = {
          'type': 'attendance',
          'status': log['status'] ?? 'Hadir',
          'waktuIn': log['waktuIn'],
          'waktuOut': log['waktuOut'],
          'lokasi': log['lokasiNama'] ?? 'Kantor',
          'isTepat': log['isTepat'] ?? true,
        };
      }
    }

    final userLeaves = leaveApps.where((leave) {
      final u = (leave['username'] ?? leave['id'] ?? '')
          .toString()
          .trim()
          .toUpperCase();
      return u == cleanUser;
    }).toList();
    for (var leave in userLeaves) {
      final tglRange = leave['tanggal']?.toString() ?? '';
      final jenis = leave['jenis']?.toString() ?? 'Pengajuan';
      final status = leave['status']?.toString() ?? 'MENUNGGU';

      final createdAt = leave['createdAt']?.toString() ?? '';
      if (createdAt.isNotEmpty) {
        final cleanDate = createdAt.substring(0, 10);
        dateMap[cleanDate] = {
          'type': 'leave',
          'jenis': jenis,
          'status': status,
          'tanggalRange': tglRange,
          'alasan': leave['alasan'] ?? '-',
        };
      }
    }
  } catch (_) {}

  return dateMap;
});

enum CalendarViewMode { week, month }

class BerandaCalendar extends ConsumerStatefulWidget {
  const BerandaCalendar({super.key});

  @override
  ConsumerState<BerandaCalendar> createState() => _BerandaCalendarState();
}

class _BerandaCalendarState extends ConsumerState<BerandaCalendar> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  CalendarViewMode _viewMode = CalendarViewMode.week;

  static const List<String> _namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  static const List<String> _namaHariShort = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min'
  ];

  static const List<String> _namaHariFull = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousPeriod() {
    setState(() {
      if (_viewMode == CalendarViewMode.week) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      } else {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_viewMode == CalendarViewMode.week) {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
        _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      } else {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      }
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _focusedMonth = DateTime(now.year, now.month, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  String _formatKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  List<DateTime> _getDaysInWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final calendarDataAsync = ref.watch(calendarDataProvider);
    final dateMap = calendarDataAsync.value ?? {};

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.calendar,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Kalender Kerja',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildViewModeToggle(),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_namaBulan[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Row(
                children: [
                  if (!_isToday(_selectedDate))
                    InkWell(
                      onTap: _jumpToToday,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Hari Ini',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: _previousPeriod,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(LucideIcons.chevronLeft,
                          size: 18, color: AppColors.onSurface),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: _nextPeriod,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(LucideIcons.chevronRight,
                          size: 18, color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _viewMode == CalendarViewMode.week
                ? _buildWeekView(dateMap)
                : _buildMonthView(dateMap),
          ),
          const SizedBox(height: 16),
          _buildSelectedDateDetail(dateMap),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _viewMode = CalendarViewMode.week;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _viewMode == CalendarViewMode.week
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'Minggu',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _viewMode == CalendarViewMode.week
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _viewMode = CalendarViewMode.month;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _viewMode == CalendarViewMode.month
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'Bulan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _viewMode == CalendarViewMode.month
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(Map<String, Map<String, dynamic>> dateMap) {
    final days = _getDaysInWeek(_selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isSelected = _isSameDay(day, _selectedDate);
        final isToday = _isToday(day);
        final isSunday = day.weekday == DateTime.sunday;
        final key = _formatKey(day);
        final hasData = dateMap.containsKey(key);

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
                _focusedMonth = DateTime(day.year, day.month, 1);
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.ipmOrange, AppColors.ipmOrangeDark],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isToday
                        ? AppColors.surfaceContainer
                        : AppColors.surface),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isToday
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.border.withOpacity(0.5)),
                  width: isSelected || isToday ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _namaHariShort[day.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.onPrimary.withOpacity(0.9)
                          : (isSunday
                              ? AppColors.error
                              : AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.onPrimary
                          : (isSunday ? AppColors.error : AppColors.onSurface),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildEventDot(
                      hasData ? dateMap[key] : null, isSunday, isSelected),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthView(Map<String, Map<String, dynamic>> dateMap) {
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday;

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      final isSunday = i == 6;
      dayWidgets.add(
        Center(
          child: Text(
            _namaHariShort[i],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSunday ? AppColors.error : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    for (int i = 1; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final dt = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _isSameDay(dt, _selectedDate);
      final isToday = _isToday(dt);
      final isSunday = dt.weekday == DateTime.sunday;
      final key = _formatKey(dt);
      final hasData = dateMap.containsKey(key);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = dt;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isToday ? AppColors.surfaceContainer : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            // Stack keeps day number and status dot inside compact cells.
            // Column needs more height than small phone calendar cells provide.
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? AppColors.onPrimary
                        : (isSunday ? AppColors.error : AppColors.onSurface),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  child: _buildEventDot(
                      hasData ? dateMap[key] : null, isSunday, isSelected),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: dayWidgets,
    );
  }

  Widget _buildEventDot(
      Map<String, dynamic>? data, bool isSunday, bool isSelected) {
    Color dotColor = Colors.transparent;

    if (data != null) {
      if (data['type'] == 'attendance') {
        dotColor =
            data['isTepat'] == false ? AppColors.warning : AppColors.success;
      } else if (data['type'] == 'leave') {
        dotColor = AppColors.ipmOrange;
      }
    } else if (isSunday) {
      dotColor = AppColors.border;
    }

    if (dotColor == Colors.transparent) {
      return const SizedBox(height: 5);
    }

    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: isSelected && dotColor != AppColors.border
            ? AppColors.onPrimary
            : dotColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSelectedDateDetail(Map<String, Map<String, dynamic>> dateMap) {
    final key = _formatKey(_selectedDate);
    final data = dateMap[key];
    final isSunday = _selectedDate.weekday == DateTime.sunday;
    final hariStr = _namaHariFull[_selectedDate.weekday - 1];
    final tglStr =
        '${_selectedDate.day} ${_namaBulan[_selectedDate.month - 1]} ${_selectedDate.year}';

    String statusTitle = 'Hari Kerja Regular';
    String statusSubtitle = 'Belum ada presensi';
    IconData icon = LucideIcons.briefcase;
    Color iconBg = AppColors.primaryFixed;
    Color iconColor = AppColors.onPrimaryFixed;

    if (isSunday) {
      statusTitle = 'Hari Minggu (Libur)';
      statusSubtitle = 'Tidak ada jadwal jam kerja kantor';
      icon = LucideIcons.coffee;
      iconBg = AppColors.neutralBg;
      iconColor = AppColors.onSurfaceVariant;
    } else if (data != null) {
      if (data['type'] == 'attendance') {
        final inTime = data['waktuIn'] ?? '-';
        final outTime = data['waktuOut'] ?? 'Belum Check-out';
        statusTitle = 'Presensi Hadir';
        statusSubtitle = 'Masuk: $inTime | Keluar: $outTime';
        icon = LucideIcons.checkCircle;
        iconBg = AppColors.surfaceContainerHigh;
        iconColor = AppColors.success;
      } else if (data['type'] == 'leave') {
        final jenis = data['jenis'] ?? 'Izin';
        final st = data['status'] ?? 'MENUNGGU';

        statusTitle = 'Pengajuan $jenis ($st)';
        statusSubtitle = 'Alasan: ${data['alasan']}';
        icon = LucideIcons.fileText;
        iconBg = AppColors.ipmOrangeSoft;
        iconColor = AppColors.ipmOrangeDark;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$hariStr, $tglStr',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    if (_isToday(_selectedDate)) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HARI INI',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  statusTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
