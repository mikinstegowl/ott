import 'package:ottapp/Localization/AppTranslations.dart';

/// The words the app says, in whichever language the viewer chose.
///
/// Getters rather than fields: a field is evaluated once when the class is
/// first touched, which would freeze the language at startup and leave the
/// app in the old one after a switch. A getter is read each time it is used.
///
/// Call sites are unchanged — `AppText.watchNow` still reads the same.
///
/// Section type identifiers used to live here too. They are strings the
/// server sends, not words anyone reads, so they now live in SectionTypes
/// where a translation pass cannot reach them.
class AppText {
  static final appName = 'streamit'.toUpperCase();

  static String get watchNow => AppTranslations.resolve('common.watch_now');
  static String get playNow => AppTranslations.resolve('common.play_now');
  static String get load_more => AppTranslations.resolve('common.load_more');

  static String get bottombar_home => AppTranslations.resolve('nav.home');
  static String get bottombar_vdeos => AppTranslations.resolve('nav.live_video');
  static String get bottomBar_search => AppTranslations.resolve('nav.search');
  static String get bottomBar_tvShow => AppTranslations.resolve('nav.tv_shows');
  static String get bottomBar_profile => AppTranslations.resolve('nav.profile');

  // Sign in
  static String get emailAddress => AppTranslations.resolve('auth.email_address');
  static String get enterEmail => AppTranslations.resolve('auth.enter_email');
  static String get password => AppTranslations.resolve('auth.password');
  static String get login => AppTranslations.resolve('auth.login');
  static String get ifYouAreNew => AppTranslations.resolve('auth.if_you_are_new');
  static String get signUp => AppTranslations.resolve('auth.sign_up');
  static String get orText => AppTranslations.resolve('auth.or');
  static String get continueWithSub =>
      AppTranslations.resolve('auth.continue_with_subscription');

  // Sign up
  static String get fullName => AppTranslations.resolve('auth.full_name');
  static String get enterName => AppTranslations.resolve('auth.enter_name');
  static String get phoneOptional => AppTranslations.resolve('auth.phone_optional');
  static String get enterPhone => AppTranslations.resolve('auth.enter_phone');
  static String get confirmPassword => AppTranslations.resolve('auth.confirm_password');
  static String get confirmPasswordHint =>
      AppTranslations.resolve('auth.confirm_password_hint');
  static String get alreadyHaveAccount =>
      AppTranslations.resolve('auth.already_have_account');
  static String get signIn => AppTranslations.resolve('auth.sign_in');
}
