import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// 🔹 Initialize Notifications
  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iOSInitSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidInitSettings,
      iOS: iOSInitSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print("🔔 Notification Clicked: ${response.payload}");
      },
    );

    if (Platform.isAndroid) {
      await _requestExactAlarmPermission();
    }

    await requestPermissions();
  }

  /// 🔹 Request Notification Permissions
  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      if (!await Permission.notification.isGranted) {
        await Permission.notification.request();
      }
    } else {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// 🔹 Request Exact Alarm Permission (Android 12+)
  static Future<void> _requestExactAlarmPermission() async {
    if (Platform.isAndroid && await _needsExactAlarmPermission()) {
      print("🔴 Exact Alarm permission required! Redirecting to settings...");
      openAppSettings();
    }
  }

  /// 🔹 Check if Exact Alarm Permission is Needed (Android 12+)
  static Future<bool> _needsExactAlarmPermission() async {
    if (Platform.isAndroid) {
      int sdkInt = int.tryParse(Platform.version.split(".")[0]) ?? 0;
      if (sdkInt >= 31) {
        return !(await Permission.scheduleExactAlarm.isGranted);
      }
    }
    return false;
  }

  /// 🔹 Show Scheduled Notification
  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (Platform.isAndroid && await _needsExactAlarmPermission()) {
      print("⚠️ Cannot schedule notification: Exact Alarm Permission Required!");
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Scheduled Notifications',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          playSound: true,
          enableLights: true,
          enableVibration: true,
          ongoing: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 🔹 Show Instant Notification (Works in Foreground & Background)
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Instant Notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

