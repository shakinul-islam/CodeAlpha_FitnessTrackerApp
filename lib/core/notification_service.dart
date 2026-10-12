
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _enabledKey =
      'water_reminder_enabled';

  static const int _waterReminderId = 1001;

  static const String _waterChannelId =
      'water_reminder_channel_v3';

  bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    // IMPORTANT:
    // Initialize plugin BEFORE requesting permissions.
    await _plugin.initialize(
      settings: settings,
    );

    _initialized = true;

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Android 13+
    await androidPlugin?.requestNotificationsPermission();

    // Create the notification channel explicitly.
    const AndroidNotificationChannel channel =
        AndroidNotificationChannel(
      _waterChannelId,
      'Water Reminder',
      description:
          'Hydration reminders to help maintain daily water intake.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await androidPlugin?.createNotificationChannel(
      channel,
    );

    final prefs =
        await SharedPreferences.getInstance();

    final enabled =
        prefs.getBool(
              _enabledKey,
            ) ??
            false;

    if (!enabled) {
      return;
    }

    // Do NOT blindly create another repeating notification
    // every time the application opens.
    //
    // First check whether the reminder already exists.
    final pending =
        await _plugin.pendingNotificationRequests();

    final alreadyScheduled =
        pending.any(
      (notification) =>
          notification.id == _waterReminderId,
    );

    if (alreadyScheduled) {
      return;
    }

    // If Android removed the scheduled alarm,
    // attempt to restore it.
    final canSchedule =
        await _canScheduleExactNotifications();

    if (canSchedule) {
      try {
        await _scheduleWaterReminder();
      } catch (_) {
        // Do not crash app startup.
      }
    }
  }

  // ============================================================
  // CURRENT SETTING
  // ============================================================

  Future<bool> isWaterReminderEnabled() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          _enabledKey,
        ) ??
        false;
  }

  // ============================================================
  // EXACT ALARM STATUS
  // ============================================================

  Future<bool>
      _canScheduleExactNotifications() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return true;
    }

    final allowed =
        await androidPlugin
            .canScheduleExactNotifications();

    // Some Android versions return null because
    // special exact-alarm permission isn't needed.
    return allowed ?? true;
  }

  // ============================================================
  // REQUEST EXACT ALARM ACCESS
  // ============================================================

  Future<bool>
      _ensureExactAlarmPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return true;
    }

    var allowed =
        await androidPlugin
            .canScheduleExactNotifications();

    if (allowed == true ||
        allowed == null) {
      return true;
    }

    await androidPlugin
        .requestExactAlarmsPermission();

    // IMPORTANT:
    // Check again instead of trusting the request result.
    allowed =
        await androidPlugin
            .canScheduleExactNotifications();

    return allowed ?? true;
  }

  // ============================================================
  // ENABLE / DISABLE WATER REMINDER
  // ============================================================

  Future<bool> setWaterReminderEnabled(
    bool enabled,
  ) async {
    if (!_initialized) {
      await init();
    }

    final prefs =
        await SharedPreferences.getInstance();

    if (!enabled) {
      await _plugin.cancel(
        id: _waterReminderId,
      );

      await prefs.setBool(
        _enabledKey,
        false,
      );

      return true;
    }

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // ----------------------------------------------------------
    // Notification Permission
    // ----------------------------------------------------------

    final notificationPermission =
        await androidPlugin
            ?.requestNotificationsPermission();

    if (notificationPermission ==
        false) {
      await prefs.setBool(
        _enabledKey,
        false,
      );

      return false;
    }

    // ----------------------------------------------------------
    // Exact Alarm Permission
    // ----------------------------------------------------------

    final exactAlarmAllowed =
        await _ensureExactAlarmPermission();

    if (!exactAlarmAllowed) {
      await prefs.setBool(
        _enabledKey,
        false,
      );

      return false;
    }

    try {
      // Remove old/pending schedule.
      await _plugin.cancel(
        id: _waterReminderId,
      );

      // Create a new repeating reminder.
      await _scheduleWaterReminder();

      // Verify that Android accepted the schedule.
      final pending =
          await _plugin
              .pendingNotificationRequests();

      final scheduled =
          pending.any(
        (notification) =>
            notification.id ==
            _waterReminderId,
      );

      if (!scheduled) {
        await prefs.setBool(
          _enabledKey,
          false,
        );

        return false;
      }

      await prefs.setBool(
        _enabledKey,
        true,
      );

      return true;
    } catch (_) {
      await prefs.setBool(
        _enabledKey,
        false,
      );

      return false;
    }
  }

  // ============================================================
  // CHECK WHETHER REMINDER IS ACTUALLY SCHEDULED
  // ============================================================

  Future<bool>
      isWaterReminderScheduled() async {
    final pending =
        await _plugin
            .pendingNotificationRequests();

    return pending.any(
      (notification) =>
          notification.id ==
          _waterReminderId,
    );
  }

  // ============================================================
  // WATER REMINDER
  // ============================================================

  Future<void>
      _scheduleWaterReminder() async {
    const AndroidNotificationDetails
        androidDetails =
        AndroidNotificationDetails(
      _waterChannelId,
      'Water Reminder',
      channelDescription:
          'Hydration reminders to help maintain daily water intake.',

      importance:
          Importance.high,

      priority:
          Priority.high,

      icon:
          '@mipmap/ic_launcher',

      playSound:
          true,

      enableVibration:
          true,

      category:
          AndroidNotificationCategory.reminder,
    );

    const NotificationDetails
        notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await _plugin.periodicallyShow(
      id:
          _waterReminderId,

      title:
          'Time to hydrate 💧',

      body:
          'Drink some water and keep your hydration goal on track.',

      // Change this to RepeatInterval.hourly later.
      repeatInterval:
          RepeatInterval.everyMinute,

      notificationDetails:
          notificationDetails,

      androidScheduleMode:
          AndroidScheduleMode
              .exactAllowWhileIdle,
    );
  }
}
