import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> bukaPdfAman(String payload) async {
  if (payload.isEmpty) return;
  try {
    final file = File(payload);
    if (!await file.exists()) {
      debugPrint('PDF file does not exist at: $payload');
      return;
    }
    var res = await OpenFilex.open(payload);
    debugPrint('OpenFilex try 1: ${res.type} - ${res.message}');
    if (res.type != ResultType.done) {
      res = await OpenFilex.open(payload, type: "application/pdf");
      debugPrint('OpenFilex try 2: ${res.type} - ${res.message}');
    }
  } catch (e) {
    debugPrint('Error opening PDF: $e');
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  final payload = notificationResponse.payload;
  if (payload != null && payload.isNotEmpty) {
    await bukaPdfAman(payload);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Makassar')); 

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Buka Notifikasi',
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
      linux: initializationSettingsLinux,
    );

    try {
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            await bukaPdfAman(payload);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }

    try {
      final launchDetails = await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          await bukaPdfAman(payload);
        }
      }
    } catch (_) {}
  }

  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyReminders() async {
    
    final isMobileOrMacOS = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (!isMobileOrMacOS) return;

    await cancelAllNotifications();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'attendance_reminder_channel',
      'Pengingat Presensi',
      channelDescription: 'Notifikasi untuk mengingatkan jam absen masuk dan pulang',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        '⏰ Waktunya Presensi Masuk!',
        'Jangan lupa melakukan Presensi Masuk sebelum pukul 07:30 WITA ya. Semangat pagi!',
        _nextInstanceOfTime(7, 15),
        platformDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling check-in reminder: $e');
    }

    
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        2,
        '⏰ Waktunya Presensi Keluar!',
        'Jam kerja telah usai. Jangan lupa Presensi Keluar sebelum meninggalkan lokasi kerja. Hati-hati di jalan!',
        _nextInstanceOfTime(16, 0),
        platformDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling check-out reminder: $e');
    }

    
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        3,
        '🍽️ Waktunya Istirahat!',
        'Jam istirahat telah tiba (11:30 - 13:00). Selamat istirahat dan makan siang.',
        _nextInstanceOfTime(11, 30),
        platformDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling break start reminder: $e');
    }

    
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        4,
        '🏢 Waktu Istirahat Selesai',
        'Jam istirahat telah usai. Mari kembali bekerja dengan penuh semangat!',
        _nextInstanceOfTime(13, 0),
        platformDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling break end reminder: $e');
    }
  }

  Future<void> showInstantNotification(int id, String title, String body, {String? payload}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'attendance_instant_channel',
      'Notifikasi Presensi Instan',
      channelDescription: 'Notifikasi langsung untuk pengingat absen keluar & unduhan',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.show(id, title, body, platformDetails, payload: payload);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
