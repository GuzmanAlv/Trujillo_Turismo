import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'event.dart';

class ReminderService {
  final plugin = FlutterLocalNotificationsPlugin();
  bool ready = false;
  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  Future<void> initialize() async {
    if (!supported) return;
    tzdata.initializeTimeZones();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
    );
    ready = true;
  }

  int idFor(String id) =>
      id.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);
  Future<bool> schedule(CulturalEvent e) async {
    if (!ready) return false;
    final granted = await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    if (granted != true) return false;
    final at = e.start.subtract(const Duration(hours: 1));
    if (!at.isAfter(DateTime.now())) return false;
    await plugin.zonedSchedule(
      idFor(e.id),
      'Tu próximo encuentro cultural',
      '${e.title.replaceAll('\n', ' ')} · en una hora',
      tz.TZDateTime.from(at, tz.getLocation('America/Lima')),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'agenda',
          'Mi agenda cultural',
          channelDescription: 'Recordatorios de eventos guardados',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  Future<void> cancel(String id) async {
    if (ready) await plugin.cancel(idFor(id));
  }

  Future<void> nearby(List<CulturalEvent> events) async {
    if (!ready || events.isEmpty) return;
    final granted = await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    if (granted != true) return;
    await plugin.show(
      900001,
      'Cultura cerca de ti',
      '${events.length} eventos por descubrir a menos de 5 km.',
      const NotificationDetails(
        android: AndroidNotificationDetails('nearby', 'Eventos cercanos'),
      ),
    );
  }
}
