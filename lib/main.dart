import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ottapp/Bindings/BaseControllerBindings.dart';
import 'package:ottapp/Router/GetxRouter.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:ottapp/firebase_options.dart';

import 'package:ottapp/Services/FirebaseNotificationManager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM Service using FirebaseNotificationManager
  await FirebaseNotificationManager().init();
  // Register background handler (must be a top-level function or static method)
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessage);

  await UserPreference.initSharedPrefs();

  // Detect fresh install on iOS to prevent iCloud from restoring old login tokens
  if (Platform.isIOS) {
    final freshInstallFile = File(
      '${Directory.systemTemp.path}/.fresh_install',
    );
    if (!freshInstallFile.existsSync()) {
      await UserPreference.clear();
      freshInstallFile.createSync();
    }
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932), // iPhone 14 Pro Max (like your design)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          initialBinding: BaseControllerBindings(),
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.trackpad,
            },
          ),
          initialRoute:
              (Platform.isIOS ||
               UserPreference.getValue(key: PrefKeys.logInToken) != null ||
               UserPreference.getValue(key: PrefKeys.skipUser) == true)
                  ? RoutesName.mainWrapper
                  : RoutesName.logInScreen,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.black,
            primaryColor: AppColors.appColors,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.black,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.black,
            primaryColor: AppColors.appColors,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.black,
              elevation: 0,
            ),
          ),
          themeMode: ThemeMode.dark,
          onGenerateRoute: generateRoute,
        );
      },
    );
  }
}
