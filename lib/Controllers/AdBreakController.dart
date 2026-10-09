import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Models/PlayResponseModel.dart';
import 'package:ottapp/Network/AppChopperClient.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// Manual ad breaks for the app's video player.
///
/// The server's play response says where ads go — one creative pinned to one
/// exact second. This controller watches the content player, pauses it at each
/// placement, plays the creative in its own player, and resumes the content at
/// the same second.
///
/// What the viewer sees:
///   - 0:00 is a pre-roll, played before the content starts.
///   - Seeking past a placement plays the ad that was skipped over, then
///     continues to where they wanted to go.
///   - Each placement runs once per session; resuming a title later skips the
///     placements before the resume point, except the pre-roll.
///   - An ad cannot be scrubbed. Skip appears only when the creative allows it.
///
/// Mirrors the web player so both behave identically.
class AdBreakController extends GetxController {
  final RxBool inAd = false.obs;
  final Rxn<AdBreak> currentBreak = Rxn<AdBreak>();
  final Rxn<VideoPlayerController> adPlayer = Rxn<VideoPlayerController>();

  final RxInt adRemaining = 0.obs;
  final RxDouble adElapsed = 0.0.obs;
  final RxInt adIndex = 0.obs;

  AdSchedule? _schedule;
  VideoPlayerController? _content;
  VoidCallback? _contentListener;

  final Set<int> _played = <int>{};
  final Set<String> _quartilesSent = <String>{};
  final String _sessionId =
      '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(99999)}';

  double _lastContentSeconds = -1;
  double _resumeAt = 0;
  double _adLastSeconds = 0;
  bool _busy = false;

  List<AdBreak> get _breaks => _schedule?.schedule ?? const [];

  /// A stable id for this install, so one person's ad views count once even
  /// when they are not signed in.
  String get _deviceId {
    final existing = UserPreference.getValue(key: PrefKeys.adDeviceId);
    if (existing is String && existing.isNotEmpty) return existing;

    final fresh =
        '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';
    UserPreference.setValue(key: PrefKeys.adDeviceId, value: fresh);

    return fresh;
  }

  int get totalBreaks => _breaks.length;

  /// Seconds left before Skip becomes available, or null when not skippable.
  int? get skipIn {
    final after = currentBreak.value?.ad?.skippableAfter;
    if (after == null) return null;
    return max(0, (after - adElapsed.value).ceil());
  }

  bool get canSkip {
    final after = currentBreak.value?.ad?.skippableAfter;
    return after != null && adElapsed.value >= after;
  }

  // ─── Setup ──────────────────────────────────────────────────────

  /// Take the schedule from the play response. Placements already behind the
  /// resume point are marked played, so returning to a half-watched title does
  /// not replay ads the viewer already sat through.
  void load(AdSchedule? ads, {int resumeSeconds = 0}) {
    _played.clear();
    _schedule = (ads?.enabled ?? false) ? ads : null;
    _lastContentSeconds = resumeSeconds > 0 ? resumeSeconds.toDouble() : -1;

    for (final b in _breaks) {
      if (b.playAt > 0 && b.playAt < resumeSeconds) _played.add(b.placementId);
    }

    debugPrint('[Ads] ${_breaks.length} break(s), enabled=${_schedule != null}');
  }

  /// Watch the content player. Call once it is initialised.
  void attach(VideoPlayerController content) {
    detach();
    _content = content;

    _contentListener = () {
      final c = _content;
      if (c == null || !c.value.isInitialized) return;

      // Nothing plays underneath an ad.
      if (inAd.value) {
        if (c.value.isPlaying) c.pause();
        return;
      }

      final t = c.value.position.inMilliseconds / 1000.0;

      // A jump of more than a couple of seconds is a seek, not playback.
      if (_lastContentSeconds >= 0 && (t - _lastContentSeconds).abs() > 2.5) {
        _checkBreaks(_lastContentSeconds, t);
        _lastContentSeconds = t;
        return;
      }

      _checkBreaks(_lastContentSeconds, t);
      if (!inAd.value) _lastContentSeconds = t;
    };

    content.addListener(_contentListener!);
  }

  void detach() {
    if (_content != null && _contentListener != null) {
      _content!.removeListener(_contentListener!);
    }
    _contentListener = null;
    _content = null;
  }

  /// Start playback: runs the pre-roll first when there is one.
  Future<void> begin() async {
    final preroll = _breaks.firstWhereOrNull(
      (b) => b.playAt == 0 && !_played.contains(b.placementId),
    );

    if (preroll != null) {
      _played.add(preroll.placementId);
      _resumeAt = _content?.value.position.inMilliseconds != null
          ? _content!.value.position.inMilliseconds / 1000.0
          : 0;
      await _runAd(preroll);
      return;
    }

    await _content?.play();
  }

  // ─── Break detection ────────────────────────────────────────────

  void _checkBreaks(double from, double to) {
    if (inAd.value || _busy || to <= from) return;

    final due = _breaks
        .where((b) =>
            !_played.contains(b.placementId) && b.playAt > from && b.playAt <= to)
        .toList();

    if (due.isEmpty) return;

    // Play the last one skipped over; the earlier ones are consumed.
    for (final b in due) {
      _played.add(b.placementId);
    }

    _resumeAt = to;
    _runAd(due.last);
  }

  // ─── Playing a creative ─────────────────────────────────────────

  Future<void> _runAd(AdBreak slot) async {
    final url = slot.ad?.videoUrl;
    if (url == null || url.isEmpty || _content == null) return;

    _busy = true;
    await _content!.pause();

    currentBreak.value = slot;
    adIndex.value = _breaks.indexWhere((b) => b.placementId == slot.placementId) + 1;
    adElapsed.value = 0;
    adRemaining.value = slot.ad?.duration ?? 0;
    _adLastSeconds = 0;
    _quartilesSent.clear();
    inAd.value = true;

    try {
      final player = VideoPlayerController.networkUrl(Uri.parse(url));
      adPlayer.value = player;

      await player.initialize();
      adRemaining.value = player.value.duration.inSeconds;

      player.addListener(_onAdTick);

      await player.setVolume(_content!.value.volume);
      await player.play();

      _sendEvent('impression');
    } catch (e) {
      debugPrint('[Ads] could not play creative: $e');
      _sendEvent('error');
      await _endAd();
    } finally {
      _busy = false;
    }
  }

  void _onAdTick() {
    final p = adPlayer.value;
    if (p == null || !p.value.isInitialized) return;

    final t = p.value.position.inMilliseconds / 1000.0;
    final total = p.value.duration.inMilliseconds / 1000.0;

    // No scrubbing inside an ad: snap back if the position jumps forward.
    if (t - _adLastSeconds > 1.5) {
      p.seekTo(Duration(milliseconds: (_adLastSeconds * 1000).round()));
      return;
    }

    _adLastSeconds = t;
    adElapsed.value = t;
    adRemaining.value = max(0, (total - t).ceil());

    if (total > 0) {
      final pct = t / total;
      if (pct >= 0.25) _quartile('q25');
      if (pct >= 0.5) _quartile('q50');
      if (pct >= 0.75) _quartile('q75');
    }

    final finished = total > 0 && (t >= total - 0.25 || !p.value.isPlaying && t > 0 && p.value.position >= p.value.duration);
    if (finished) {
      _sendEvent('complete');
      _endAd();
    }
  }

  Future<void> skip() async {
    if (!canSkip) return;
    _sendEvent('skip');
    await _endAd();
  }

  Future<void> openAdvertiser() async {
    final url = currentBreak.value?.ad?.clickUrl;
    if (url == null || url.isEmpty) return;

    _sendEvent('click');

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _endAd() async {
    final p = adPlayer.value;
    adPlayer.value = null;

    if (p != null) {
      p.removeListener(_onAdTick);
      await p.pause();
      await p.dispose();
    }

    currentBreak.value = null;
    inAd.value = false;
    adElapsed.value = 0;
    adRemaining.value = 0;

    final c = _content;
    if (c == null) return;

    // Resume exactly where the content was interrupted.
    final target = Duration(milliseconds: (_resumeAt * 1000).round());
    if ((c.value.position - target).abs() > const Duration(milliseconds: 500)) {
      await c.seekTo(target);
    }
    _lastContentSeconds = _resumeAt;

    // Another placement may sit on the same second.
    final next = _breaks.firstWhereOrNull((b) =>
        !_played.contains(b.placementId) &&
        (b.playAt - _resumeAt).abs() < 0.5);

    if (next != null) {
      _played.add(next.placementId);
      await _runAd(next);
      return;
    }

    await c.play();
  }

  // ─── Beacons ────────────────────────────────────────────────────

  void _quartile(String name) {
    if (_quartilesSent.contains(name)) return;
    _quartilesSent.add(name);
    _sendEvent(name);
  }

  /// Fire and forget: a failed beacon must never interrupt playback.
  void _sendEvent(String event) {
    final slot = currentBreak.value;
    final ad = slot?.ad;
    if (slot == null || ad == null) return;

    final body = {
      'device_id': _deviceId,
      'session_id': _sessionId,
      if (_schedule?.placeableType != null) 'placeable_type': _schedule!.placeableType,
      if (_schedule?.placeableId != null) 'placeable_id': _schedule!.placeableId,
      'events': [
        {
          'ad_id': ad.id,
          'placement_id': slot.placementId,
          'event': event,
          'position_seconds': _resumeAt.round(),
          'at': DateTime.now().toUtc().toIso8601String(),
        }
      ],
    };

    AppChopperClient()
        .getChopperService<HomeChopperService>()
        .sendAdEvents(body, Platform.isIOS ? 'ios' : 'android')
        .catchError((e) {
      debugPrint('[Ads] beacon failed ($event): $e');
      return null as dynamic;
    });
  }

  @override
  void onClose() {
    detach();
    adPlayer.value?.dispose();
    super.onClose();
  }
}
