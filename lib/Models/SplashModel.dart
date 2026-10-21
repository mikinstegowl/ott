/// The start-up slideshow the server sends while the app is launching.
class SplashResponse {
  bool success = false;
  List<SplashSlide> slides = [];
  int defaultDurationMs = 3000;

  SplashResponse();

  SplashResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;

    final data = json['data'];
    if (data is Map) {
      defaultDurationMs =
          (data['default_duration_ms'] as num?)?.toInt() ?? 3000;

      final list = data['slides'];
      if (list is List) {
        slides = list
            .whereType<Map>()
            .map((e) => SplashSlide.fromJson(Map<String, dynamic>.from(e)))
            .where((s) => s.image.isNotEmpty)
            .toList();
      }
    }
  }
}

class SplashSlide {
  int id = 0;
  String image = '';
  String? headline;
  String? subheadline;
  int? durationMs;

  SplashSlide();

  SplashSlide.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt() ?? 0;
    image = (json['image'] as String?) ?? '';
    headline = json['headline'] as String?;
    subheadline = json['subheadline'] as String?;
    durationMs = (json['duration_ms'] as num?)?.toInt();
  }

  bool get hasText =>
      (headline != null && headline!.isNotEmpty) ||
      (subheadline != null && subheadline!.isNotEmpty);
}
