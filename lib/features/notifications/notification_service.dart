import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// High-Impact Local Notification Service delivering behavioral coaching nudges.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  /// Schedules daily behavioral check-in notification for a habit.
  Future<void> scheduleBehavioralReminder({
    required int id,
    required String habitName,
    required int currentStreak,
    required int hour,
    required int minute,
  }) async {
    await initialize();

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    String title;
    String body;

    if (currentStreak >= 3) {
      title = '🔥 Protect your $currentStreak-day streak!';
      body = 'Don\'t break the chain for "$habitName". Complete your check-in today!';
    } else {
      title = '⚡ Anchor your daily habit: $habitName';
      body = 'A 2-minute check-in is all it takes to build unbreakable consistency.';
    }

    const androidDetails = AndroidNotificationDetails(
      'streakbox_behavioral_coaching',
      'Habit Behavioral Coaching',
      channelDescription: 'Smart notifications with loss aversion and momentum reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels scheduled reminder for a specific habit ID.
  Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
