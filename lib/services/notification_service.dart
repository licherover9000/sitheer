import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _timerChannel =
      AndroidNotificationChannel(
        'timer_channel',
        'Timer',
        description: 'Alerts when a focus or break session ends',
        importance: Importance.high,
      );

  static const AndroidNotificationChannel _scheduleChannel =
      AndroidNotificationChannel(
        'schedule_channel',
        'Schedule',
        description: 'Reminders before calendar events',
        importance: Importance.defaultImportance,
      );

  static bool _ready = false;

  static Future<void> _configureLocalTimeZone() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  static Future<void> init() async {
    if (_ready) return;

    await _configureLocalTimeZone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(settings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(_timerChannel);
    await androidImpl?.createNotificationChannel(_scheduleChannel);
    await androidImpl?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _ready = true;
  }

  static int _stableNotificationId(String eventId) {
    final h = Object.hash(2, eventId) & 0x7fffffff;
    return h == 0 ? 1 : h;
  }

  static String _formatClock(DateTime t) {
    final m = t.minute.toString().padLeft(2, '0');
    return '${t.hour}:$m';
  }

  /// Schedules a reminder a few minutes before [startLocal] (default: 10 minutes if still in the future).
  static Future<void> scheduleEventReminder({
    required String eventId,
    required String title,
    required DateTime startLocal,
  }) async {
    if (!_ready) return;

    final now = DateTime.now();
    if (!startLocal.isAfter(now)) return;

    const lead = Duration(minutes: 10);
    var when = startLocal.subtract(lead);
    if (!when.isAfter(now)) {
      when = startLocal.subtract(const Duration(minutes: 1));
      if (!when.isAfter(now)) return;
    }

    final id = _stableNotificationId(eventId);
    await _plugin.cancel(id);

    final scheduled = tz.TZDateTime.from(when, tz.local);

    await _plugin.zonedSchedule(
      id,
      'Soon: $title',
      'Starts at ${_formatClock(startLocal)}',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel',
          'Schedule',
          channelDescription: 'Reminders before calendar events',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
        macOS: DarwinNotificationDetails(presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  static Future<void> showSessionComplete(String label) async {
    if (!_ready) return;

    await _plugin.show(
      0,
      'Session complete',
      '$label finished.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_channel',
          'Timer',
          channelDescription: 'Alerts when a focus or break session ends',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
        macOS: DarwinNotificationDetails(presentSound: true),
      ),
    );
  }
}
