import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  Future<void> scheduleFeedingReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final millisecondsFromNow = scheduledDate.millisecondsSinceEpoch -
        DateTime.now().millisecondsSinceEpoch;

    await _plugin.schedule(
      id,
      title,
      body,
      millisecondsFromNow,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'feeding_reminders',
          '喂食提醒',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }
}