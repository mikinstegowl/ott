import 'dart:io';

import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';

class RoutesName {
  static const String splashScreen = 'splashScreen';
  static const String logInScreen = 'logInScreen';
  static const String registerScreen = 'registerScreen';
  static const String forgotPasswordScreen = 'forgotPasswordScreen';
  static const String profileScreen = 'profileScreen';
  static const String changePasswordScreen = 'changePasswordScreen';
  static const String homeScreen = 'homeScreen';
  static const String infoScreen = 'infoScreen';
  static const String playerScreen = 'playerScreen';
  static const String viewAllScreen = 'viewAllScreen';
  static const String mainWrapper = 'mainWrapper';
  static const String liveVideoScreen = 'liveVideoScreen';
  static const String watchlistScreen = 'watchlistScreen';
  static const String searchScreen = 'searchScreen';
  static const String reelShortsScreen = 'reelShortsScreen';
}

/// Where the app lands once the start-up slideshow has finished.
///
/// Kept here rather than in main.dart so the splash route and the app's
/// entry point cannot drift apart: both ask the same question.
String startDestination() {
  final signedIn = UserPreference.getValue(key: PrefKeys.logInToken) != null;
  final skipped = UserPreference.getValue(key: PrefKeys.skipUser) == true;

  // iOS never shows the sign-in wall first: the store requires the catalogue
  // to be browsable without an account.
  return (Platform.isIOS || signedIn || skipped)
      ? RoutesName.mainWrapper
      : RoutesName.logInScreen;
}

/// Whether to show the start-up slideshow at all.
///
/// It greets someone by name and offers their profile, which only means
/// anything once they have signed in. A signed-out viewer would be shown a
/// nameless tile for no reason, so they go straight through.
bool shouldShowSplash() =>
    UserPreference.getValue(key: PrefKeys.logInToken) != null;
