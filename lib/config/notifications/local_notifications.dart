import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:fraseapp/core/core.dart';
import 'package:fraseapp/config/config.dart';

class LocalNotifications {

  static Future<void> requestPermissionsLocalNotifications( BuildContext context, TextTheme textStyles ) async {

    await Future.delayed(const Duration(seconds: 2));

    final storageService = StorageService();

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final bool? areEnabled = await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.areNotificationsEnabled();

    if ( areEnabled != null && areEnabled ) return;

    // show dialog to ask if you want to activate notifications
    if ( !context.mounted ) return;
    final isGranted = await openGrantedNotificationDialog( context, textStyles );
    if ( !isGranted ) {
      await storageService.setOrDeleteWaitingTimeToRequestNotification( RequestNotification.denied );
      return;
    }

    await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();

    // await flutterLocalNotificationsPlugin
    // .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    // ?.requestExactAlarmsPermission();

  }

  // init local notifications (android)
  static Future<void> initializeLocalNotifications() async {

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

  }

  static Future<void> scheduleDailyNotification() async {

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    // set notification time (8 AM)
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, 
      'Ya viste la frase del día ✍🏼', 
      '¡Una nueva frase te espera!',
      scheduledDate, 
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time
    );

  }

  // What to do when a notification is touched
  static void onDidReceiveNotificationResponse( NotificationResponse response ) {
    appRouter.go('/'); 
  }

  static Future<bool> openGrantedNotificationDialog( BuildContext context, TextTheme textStyles ) async {

    bool granted = false;

    await showDialog(
      useSafeArea: true,
      context: context, 
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(0.5),
          title: Center(child: Text("❤", style: textStyles.titleSmall)),
          content: const Text(
            "¿Deseas que te avisemos cuando haya una nueva frase?", 
            style: TextStyle(fontSize: 18), textAlign: TextAlign.center
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                granted = true;
                Navigator.pop(context);
              },
              child: const Text("Si"),
            ),
            TextButton(
              onPressed: () {
                granted = false;
                Navigator.pop(context);
              },
              child: const Text("Despues")
            ),
          ],
        );
      }
    );

    return granted;

  }

}