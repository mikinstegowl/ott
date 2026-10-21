class PrefKeys {
  static const String logInToken = "logInToken";
  /// Anonymous, per-install id used to count unique ad viewers.
  static const String adDeviceId = "adDeviceId";
  static const String genresId = 'genres_id';
  static const String userId = 'userId';
  static const String skipUser = 'skipUser';
  static const String firstTime = 'firstTime';
  static const String emailID = 'emailID';
  static const String subscriptionStatus = 'subscriptionStatus';

  /// The language the viewer chose, as a two-letter code.
  ///
  /// Read before the first frame so the app opens in the right language
  /// rather than switching a moment later.
  static const String language = 'language';

}
