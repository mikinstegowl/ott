import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Models/SplashModel.dart';
import 'package:ottapp/Network/AppChopperClient.dart';

/// The screen the app opens on: a promotional slider above, and the profile
/// to watch as below.
///
/// Netflix shows several profiles here; TrebolPlus has one account per person,
/// so there is a single tile and tapping it goes in. The tap is kept rather
/// than opening automatically because it is what makes the promotion worth
/// having — the viewer reads the slide instead of it flashing past.
///
/// The slides come from the server so the client can change them without
/// shipping a release, which means this screen has to work when the server is
/// slow or unreachable: it waits briefly, then shows the profile on its own.
class SplashController extends BaseController {
  SplashController({required this.onContinue});

  /// Where tapping the profile leads. Decided by the router, so this
  /// controller never has to know the sign-in rules.
  final VoidCallback onContinue;

  /// How long to wait for slides before showing the profile without them.
  static const _fetchTimeout = Duration(seconds: 3);

  final RxList<SplashSlide> slides = <SplashSlide>[].obs;
  final RxInt index = 0.obs;
  final RxBool ready = false.obs;

  final PageController pageController = PageController();

  int _defaultDurationMs = 3000;
  Timer? _advance;
  bool _entered = false;

  /// The name on the profile tile.
  ///
  /// Falls back to Guest rather than something vague like "You": if we have no
  /// name it is because nobody is signed in, and saying so is more honest than
  /// addressing an account we do not have.
  String get profileName {
    final name = profileData.value?.data?.name;
    if (name != null && name.trim().isNotEmpty) return name.trim();

    return 'Guest';
  }

  String get profileInitial {
    final n = profileName;
    return n.isNotEmpty ? n.substring(0, 1).toUpperCase() : 'U';
  }

  String? get profileAvatar => profileData.value?.data?.avatar;

  @override
  void onInit() {
    super.onInit();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    try {
      final response = await AppChopperClient()
          .getChopperService<HomeChopperService>()
          .getSplashSlides()
          .timeout(_fetchTimeout);

      final body = response.body;
      if (response.isSuccessful && body is Map) {
        final parsed = SplashResponse.fromJson(Map<String, dynamic>.from(body));
        _defaultDurationMs = parsed.defaultDurationMs;
        slides.assignAll(parsed.slides);
      }
    } catch (e) {
      debugPrint('[Splash] could not load slides: $e');
    }

    ready.value = true;

    if (slides.length > 1) _scheduleNext();
  }

  /// Cycles the slider. Unlike the old full-screen splash this loops rather
  /// than ending, because nothing happens until the viewer taps.
  void _scheduleNext() {
    _advance?.cancel();

    final ms = slides[index.value].durationMs ?? _defaultDurationMs;

    _advance = Timer(Duration(milliseconds: ms), () {
      if (slides.isEmpty) return;

      final next = (index.value + 1) % slides.length;
      index.value = next;

      if (pageController.hasClients) {
        pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      }

      _scheduleNext();
    });
  }

  /// A swipe should not fight the timer, so restart it from the new slide.
  void onSlideChanged(int i) {
    index.value = i;
    if (slides.length > 1) _scheduleNext();
  }

  void enter() {
    if (_entered) return;
    _entered = true;

    _advance?.cancel();
    onContinue();
  }

  @override
  void onClose() {
    _advance?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
