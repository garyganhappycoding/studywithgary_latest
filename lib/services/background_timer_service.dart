import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';


class BackgroundTimerService {
  static final BackgroundTimerService _instance =
  BackgroundTimerService._internal();


  factory BackgroundTimerService() {
    return _instance;
  }


  BackgroundTimerService._internal();


  static const String timerChannelId = 'timer_channel';
  static const int timerNotificationId = 888;


  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();


  // Initialize background service
  static Future<void> initializeBackgroundService() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('app_icon');


    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
    );


    await _notificationsPlugin.initialize(settings: initializationSettings );


    // ✅ CREATE CHANNEL THE SIMPLE WAY
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'timer_channel', // id (positional)
      'Study Timer', // name (positional)
    );


    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);


    final service = FlutterBackgroundService();


    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          autoStart: true,
          foregroundServiceTypes: [AndroidForegroundType.dataSync]
      ),
    );


    service.startService();
  }


  // Background service callback for Android
  static void onStart(ServiceInstance service) async {
    // Only for Android
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });


      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }


    service.on('stop').listen((event) {
      service.stopSelf();
    });


    // Timer update loop
    service.on('updateTimer').listen((dynamic event) async {
      // ✅ FIX: Safe extraction with null checks
      if (event == null) return;


      // Extract values safely
      dynamic remainingSecondsRaw = event['remainingSeconds'];
      dynamic isBreakRaw = event['isBreak'];
      dynamic isLongBreakRaw = event['isLongBreak'];


      // ✅ FIX: Convert to proper types
      int remainingSeconds = 0;
      if (remainingSecondsRaw is int) {
        remainingSeconds = remainingSecondsRaw;
      } else if (remainingSecondsRaw is double) {
        remainingSeconds = remainingSecondsRaw.toInt();
      }


      bool isBreak = (isBreakRaw is bool) ? isBreakRaw : false;
      bool isLongBreak = (isLongBreakRaw is bool) ? isLongBreakRaw : false;


      String displayText = _formatTime(remainingSeconds);
      String title = '';


      // ✅ FIX: Now isBreak and isLongBreak are guaranteed to be bool
      if (isBreak && isLongBreak) {
        title = '☕ Long Break - $displayText';
      } else if (isBreak) {
        title = '🧘 Short Break - $displayText';
      } else {
        title = '📚 Focus Time - $displayText';
      }


      // Update notification
      await _updateNotification(title, displayText);
    });
  }


  // iOS background callback
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }


  // Update notification with timer
  static Future<void> _updateNotification(
      String title, String displayTime) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'timer_channel',
        'Study Timer',
        channelDescription: 'Timer for study sessions',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
      );


      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );


      await _notificationsPlugin.show(
        id: timerNotificationId,
        title: title,
        body: displayTime,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      print('Error updating notification: $e');
    }
  }


  static String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }


  // Stop background service
  static Future<void> stopBackgroundService() async {
    try {
      final service = FlutterBackgroundService();
      if (service.isRunning==true) {
        service.invoke('stop');
      }
      await _notificationsPlugin.cancel(id: timerNotificationId);
    } catch (e) {
      print('Error stopping background service: $e');
    }
  }


  // Send timer update to background service
  static Future<void> updateTimerInBackground({
    required int remainingSeconds,
    required bool isBreak,
    required bool isLongBreak,
  }) async {
    try {
      final service = FlutterBackgroundService();
      if (service.isRunning == true ) {
        service.invoke('updateTimer', {
          'remainingSeconds': remainingSeconds,
          'isBreak': isBreak,
          'isLongBreak': isLongBreak,
        });
      }
    } catch (e) {
      print('Error updating timer in background: $e');
    }
  }
}

