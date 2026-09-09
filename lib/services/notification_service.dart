import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Wraps flutter_local_notifications for the Daily Routine reminders.
/// Entirely on-device — reminders fire with zero internet connectivity,
/// which is the whole point for patients in low-connectivity areas.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// flutter_local_notifications only ships Android/iOS/macOS engines — the
  /// real target here is an Android tablet, so Windows/Linux (used only for
  /// fast desktop dev-testing) simply skip scheduling reminders.
  bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  Future<void> init() async {
    if (_initialized || !_supported) return;

    tz_data.initializeTimeZones();
    try {
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Fall back to UTC if the platform can't report a timezone name.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.createNotificationChannel(const AndroidNotificationChannel(
      'routine_reminders',
      'Daily Routine Reminders',
      description: 'Medicine, hydration, activity and appointment reminders',
      importance: Importance.high,
    ));
    await androidImpl?.createNotificationChannel(const AndroidNotificationChannel(
      'caregiver_alerts',
      'Caregiver Alerts',
      description: 'Missed reminders and notable changes in game performance',
      importance: Importance.high,
    ));
    // Without this, Android silently downgrades every reminder to an inexact,
    // batched alarm (observed several minutes late in testing) -- too
    // imprecise for medicine reminders. There's no in-app dialog for this
    // permission; it deep-links to the system Settings screen instead.
    if (await androidImpl?.canScheduleExactNotifications() != true) {
      await androidImpl?.requestExactAlarmsPermission();
    }

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  /// Stable numeric id for a routine so we can find/cancel its notification
  /// later — routine ids are uuid strings, notification ids must be ints.
  int _notificationIdFor(String routineItemId) =>
      routineItemId.hashCode & 0x7fffffff;

  Future<void> scheduleDaily({
    required String routineItemId,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_supported) return;
    final id = _notificationIdFor(routineItemId);
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    // Re-checked per call (not cached from init) since the caregiver may
    // grant this from system Settings at any time after the app starts.
    final canExact = await androidImpl?.canScheduleExactNotifications() ?? false;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'routine_reminders',
          'Daily Routine Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(String routineItemId) async {
    if (!_supported) return;
    await _plugin.cancel(_notificationIdFor(routineItemId));
  }

  /// Fires immediately, unlike [scheduleDaily] -- used for caregiver alerts
  /// (missed reminders, game accuracy declines), which are detected at check
  /// time rather than scheduled in advance. [id] should be stable per alert
  /// so re-detecting the same one (harmlessly, per the DB's conflict-ignore)
  /// doesn't duplicate the notification either.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_supported) return;
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'caregiver_alerts',
          'Caregiver Alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
