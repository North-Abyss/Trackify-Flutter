// lib/services/notification_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart'; // REQUIRED for kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return; // <--- SKIP INITIALIZATION ON DESKTOP
    }
    
    // 2. Desktop & Mobile Initialization
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const LinuxInitializationSettings initializationSettingsLinux = 
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  static Future<void> requestPermissions() async {

    if (kIsWeb) {
      // Browsers handle permissions automatically when you show the first notification.
      return; 
    }

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleDailyReminder() async {
    
    // 1. Web browsers and Desktop OS cannot schedule local background alarms. Skip gracefully!
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      debugPrint("Web/Desktop mode: Skipping background scheduling.");
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Reminds you to check your habits',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: 0, 
      title: 'Trackify ⏱️',
      body: 'Don\'t break the chain! Complete your daily habits.',
      scheduledDate: _nextInstanceOf8PM(),
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, 
    );
  }

  static Future<void> showImmediateNotification(String title, String body) async {
    await _notificationsPlugin.show(
      id: 1, 
      title: title, 
      body: body, 
      notificationDetails: const NotificationDetails(), 
    );
  }

  static tz.TZDateTime _nextInstanceOf8PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0); 

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> cancelReminders() async {
    await _notificationsPlugin.cancelAll();
  }
}