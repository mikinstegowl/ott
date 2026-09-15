import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ottapp/Controllers/HomeController.dart';
import 'package:ottapp/firebase_options.dart';

/// A manager class to handle Firebase notifications in the application.
class FirebaseNotificationManager {
  static final _notification = FlutterLocalNotificationsPlugin();

  /// Initializes the notification manager, sets up Firebase messaging,
  /// and configures foreground and background notification handling.
  ///
  /// Returns a future that resolves with the current [FirebaseNotificationManager] instance.
  Future<FirebaseNotificationManager> init() async {
    await _notification.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    NotificationSettings status = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

    // Fetch and print token on initialization
    await getToken();

    // Listen for Token Rotation to keep backend updated
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('FCM Token Refreshed: $newToken');
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fcmAPI(newToken: newToken);
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
      if (Platform.isAndroid) {
        var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          "1",
          'jrtransportation',
          importance: Importance.max,
          priority: Priority.high,
        );
        var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );
        await _notification.show(
          1001,
          message.notification?.title,
          message.notification?.body,
          platformChannelSpecifics,
        );

        // Debugging output
        print(message.notification?.title);
        print(message.notification?.body);
        print(jsonEncode(message.data));
        print(int.parse(DateFormat('MMddHHmm').format(DateTime.now())));
      }
    });

    return this;
  }

  /// Retrieves the Firebase token for the device.
  ///
  /// Returns a future that resolves with the Firebase token as a string.
  Future<String> getToken() async {
    if (Platform.isIOS) {
      // Ensuring APNS token is retrieved first on iOS devices before fetching FCM token
      for (int i = 0; i < 10; i++) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return await FirebaseMessaging.instance
        .getToken()
        .then((value) {
          print(value);
          return Future.value(value ?? '');
        })
        .catchError((error) {
          return Future.value('');
        });
  }
}

/// Background message handler for Firebase notifications.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessage(RemoteMessage message) async {
  final notification = FlutterLocalNotificationsPlugin();

  // Initialize Firebase based on platform safely to avoid duplicate app initialization errors
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Notification details
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    '1',
    'jrtransportation',
    importance: Importance.max,
    priority: Priority.high,
  );
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  // Show the notification
  await notification.show(
    1002,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
  );

  // Debugging output
  print("back ${message.notification?.title}");
  print("back ${message.notification?.body}");
  print(jsonEncode(message.data));
  print(int.parse(DateFormat('MMddHHmm').format(DateTime.now())));
}
