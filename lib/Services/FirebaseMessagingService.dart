import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ottapp/Controllers/HomeController.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    // 1. Request Permission (Required for iOS and Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🔔 Notification Permission: Authorized');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('🔔 Notification Permission: Provisional');
    } else {
      print('❌ Notification Permission: Declined or Not Accepted');
    }

    // 2. Initialize Local Notifications for Foreground Popups
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
    );

    // --- NEW: Enable foreground notification presentation for iOS ---
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // ----------------------------------------------------------------

    // 3. Create High Importance Channel for Android
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 4. Get the FCM Token
    try {
      if (Platform.isIOS) {
        String? apnsToken;
        // APNs registration can take some time upon startup. Retry a few times.
        for (int i = 0; i < 10; i++) {
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(milliseconds: 500));
        }
        print('🍎 APNS TOKEN: $apnsToken');
      }
      String? token = await _messaging.getToken();
      print('🚀 FCM TOKEN: $token');
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }

    // 5. Listen for Token Rotation
    _messaging.onTokenRefresh.listen((newToken) {
      log('FCM Token Refreshed: $newToken');
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fcmAPI(newToken: newToken);
      }
    });

    // 6. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('--- 🟢 FOREGROUND MESSAGE RECEIVED ---');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Because flutter_local_notifications overrides UNUserNotificationCenterDelegate on iOS,
      // native setForegroundNotificationPresentationOptions may be bypassed.
      // Triggering local notifications manually ensures banners appear on both Android and iOS.
      if (notification != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android?.smallIcon ?? '@drawable/ic_notification',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    // 7. Handle Message Opened from Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('--- 📂 MESSAGE OPENED FROM BACKGROUND ---');
      print('Title: ${message.notification?.title}');
    });
  }

  // Define the background message handler
  @pragma('vm:entry-point')
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('--- 🌙 BACKGROUND MESSAGE RECEIVED ---');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}
