import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

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

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens based on payload
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'school_management_channel',
      'School Management Notifications',
      channelDescription: 'Notifications for school management system',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'school_management_channel',
      'School Management Notifications',
      channelDescription: 'Notifications for school management system',
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
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Attendance reminder
  Future<void> scheduleAttendanceReminder(DateTime date) async {
    final reminderDate = date.subtract(const Duration(hours: 1));
    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: 1000 + date.millisecondsSinceEpoch % 10000,
        title: 'Attendance Reminder',
        body: 'Don\'t forget to mark attendance for today!',
        scheduledDate: reminderDate,
        payload: 'attendance',
      );
    }
  }

  // Low attendance alert
  Future<void> showLowAttendanceAlert(String studentName, double percentage) async {
    await showNotification(
      id: 2000,
      title: 'Low Attendance Alert',
      body: '$studentName has low attendance: ${percentage.toStringAsFixed(1)}%',
      payload: 'low_attendance',
    );
  }

  // Grade submission notification
  Future<void> showGradeSubmittedNotification(String studentName, String subject) async {
    await showNotification(
      id: 3000,
      title: 'Grade Submitted',
      body: 'Grade for $studentName in $subject has been recorded',
      payload: 'grade_submitted',
    );
  }

  // Exam reminder
  Future<void> scheduleExamReminder(String examName, DateTime examDate) async {
    final reminderDate = examDate.subtract(const Duration(days: 1));
    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: 4000 + examDate.millisecondsSinceEpoch % 10000,
        title: 'Upcoming Exam',
        body: '$examName is scheduled for tomorrow!',
        scheduledDate: reminderDate,
        payload: 'exam_reminder',
      );
    }
  }
}

