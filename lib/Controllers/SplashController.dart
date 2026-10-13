import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Models/SplashModel.dart';
import 'package:ottapp/Network/AppChopperClient.dart';

/// Runs the start-up slideshow, then sends the viewer on.
///
/// The slides come from the server so the client can change them without
/// shipping a release. That means the app must cope with the server being
/// slow or unreachable: it waits only briefly, and if nothing arrives it
/// moves straight on rather than holding the viewer on a blank screen.
class SplashController extends GetxController {
  SplashController({required this.onFinished});

  /// Where to go once the slideshow is over. Decided by main.dart, so this
  /// controller never has to know about sign-in.
  final VoidCallback onFinished;

  /// How long to wait for the slide list before giving up and going in.
  static const _fetchTimeout = Duration(seconds: 3);

  final RxList<SplashSlide> slides = <SplashSlide>[].obs;
  final RxInt index = 0.obs;
  final RxBool ready = false.obs;

  int _defaultDurationMs = 3000;
  Timer? _advance;
  bool _left = false;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  Future<void> _start() async {
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

    if (slides.isEmpty) {
      _leave();
      return;
    }

    _scheduleNext();
  }

  void _scheduleNext() {
    _advance?.cancel();

    final slide = slides[index.value];
    final ms = slide.durationMs ?? _defaultDurationMs;

    _advance = Timer(Duration(milliseconds: ms), () {
      if (index.value >= slides.length - 1) {
        _leave();
        return;
      }

      index.value++;
      _scheduleNext();
    });
  }

  /// Tapping skips the rest. A viewer who has seen it should not have to wait.
  void skip() => _leave();

  void _leave() {
    if (_left) return;
    _left = true;

    _advance?.cancel();
    onFinished();
  }

  @override
  void onClose() {
    _advance?.cancel();
    super.onClose();
  }
}
