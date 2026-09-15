import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:ottapp/Widgets/InAppPurchase/InAppPurchaseBottomSheet.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';

class PlayerController extends BaseController {
  final HomeChopperService homeChopperService;
  PlayerController({required this.homeChopperService});

  // Data & Configuration
  final Rx<InfoModel?> contentData = Rxn<InfoModel>();
  String? contentUuid;
  String? contentType; // 'movie' or 'episode'
  int? contentId;
  int? episodeId;
  bool autoRotate = true;

  // Video Source & Initialization state
  final RxString videoSource = "upload".obs; // 'upload', 'youtube', 'vimeo' etc.
  final RxBool isInitialized = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = "".obs;
  final RxString customTitle = "".obs;

  // Video Player & Chewie
  VideoPlayerController? videoPlayerController;
  final Rxn<ChewieController> chewieController = Rxn<ChewieController>();
  final List<StreamSubscription> _subscriptions = [];

  // YouTube Specific
  yt.YoutubePlayerController? youtubeController;

  // Playback State
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;

  // Controls UI Logic
  final RxBool showControls = true.obs;
  Timer? _hideTimer;
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      contentUuid = args;
    } else if (args is Map<String, dynamic>) {
      contentUuid = args['uuid'];
      contentType = args['type'];
      autoRotate = args['autoRotate'] ?? true;
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (contentUuid != null) {
      _loadPlaybackData();
    }
    // Delay orientation change slightly to let transition finish smoothly
    if (autoRotate) {
      Future.delayed(const Duration(milliseconds: 300), () => _setFullScreen());
    }
    resetHideTimer();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _hideTimer?.cancel();
    syncWatchHistory(); // Final sync
    
    // Safety cleanup for Hot Restart
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    
    if (autoRotate) _restoreScreen();
    
    videoPlayerController?.dispose();
    chewieController.value?.dispose();
    youtubeController?.dispose();
    super.onClose();
  }

  // MARK: - Screen Orientation
  void _setFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restoreScreen() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // MARK: - Data Loading
  Future<void> _loadPlaybackData() async {
    if (contentUuid == null) return;
    try {
      showLoader(true);
      hasError.value = false;
      
      final response = contentType == 'episode' 
        ? await homeChopperService.playEpisodeAPI(contentUuid!)
        : await homeChopperService.playContentAPI(contentUuid!);

      if (response.isSuccessful && response.body != null) {
        _handlePlayResponse(response.body!);
      } else {
        _setError("Failed to load playback data");
      }
    } catch (e) {
      _setError("Network error: ${e.toString()}");
    } finally {
      showLoader(false);
    }
  }

  void _handlePlayResponse(dynamic playResponse) {
    if (playResponse.success != true) {
      if (playResponse.code == "SUBSCRIPTION_REQUIRED") {
        final context = Get.context;
        if (context != null) {
          InAppPurchaseBottomSheet.show(context);
        }
      } else {
        _setError("Unable to play this content");
      }
      return;
    }

    final data = playResponse.data;
    videoSource.value = data?.videoSource ?? 'upload';
    customTitle.value = data?.title ?? "";
    contentId = contentType != 'episode' ? data?.contentId : null;
    episodeId = contentType == 'episode' ? data?.contentId : null;

    // Quality Selection based on User-Agent / CloudFront only
    final playUrl = data?.videoUrls?.master ?? data?.videoUrls?.k4 ?? data?.watchUrl ?? data?.embedId;
    
    // Progress Handling - Extract early to pass to init
    int startSeconds = 0;
    final progress = data?.watchProgress;
    if (progress != null) {
      if (progress is int) {
        startSeconds = progress;
      } else if (progress is String) startSeconds = int.tryParse(progress) ?? 0;
      else if (progress is Map<String, dynamic>) {
        if (progress['is_completed'] != true) {
          startSeconds = (progress['position'] as num?)?.toInt() ?? 0;
        }
      }
    }

    // Start playback based on source
    if (videoSource.value == "youtube") {
      if (playUrl != null) {
        _initYoutube(playUrl, startSeconds: startSeconds);
      } else {
        _setError("YouTube source not found");
      }
    } else {
      if (playUrl != null) {
        _initNative(playUrl, startSeconds: startSeconds);
      } else {
        _setError("No video URL found");
      }
    }

    _startSyncTimer();
  }

  // MARK: - Player Initializations

  Future<void> _initYoutube(String videoId, {int startSeconds = 0}) async {
    try {
      isInitialized.value = false;
      isBuffering.value = true;

      final cleanId = yt.YoutubePlayer.convertUrlToId(videoId) ?? videoId;
      
      youtubeController = yt.YoutubePlayerController(
        initialVideoId: cleanId,
        flags: yt.YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          startAt: startSeconds,
        ),
      );

      // Listen to YouTube State
      youtubeController!.addListener(() {
        if (!youtubeController!.value.isReady) return;
        if (youtubeController!.value.hasError) {
          _setError("YouTube Error: ${youtubeController!.value.errorCode}");
        }
        
        isPlaying.value = youtubeController!.value.isPlaying;
        currentPosition.value = youtubeController!.value.position;
        totalDuration.value = youtubeController!.value.metaData.duration;
        isBuffering.value = youtubeController!.value.playerState == yt.PlayerState.buffering;
      });

      isInitialized.value = true;
    } catch (e) {
      _setError("YouTube Setup Error: ${e.toString()}");
    }
  }

  Future<void> _initNative(String url, {bool autoPlay = true, int startSeconds = 0}) async {
    try {
      isInitialized.value = false;
      isBuffering.value = true;

      final finalUrl = url.trim();

      await videoPlayerController?.dispose();
      chewieController.value?.dispose();

      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(finalUrl),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Referer': 'https://tr3bolplus.com/',
        },
      );

      await videoPlayerController!.initialize();

      chewieController.value = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: autoPlay,
        looping: false,
        startAt: Duration(seconds: startSeconds),
        fullScreenByDefault: false,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        // Use custom controls logic already in AppVideoPlayerView? 
        // Or let Chewie handle it? 
        // For now, matching the previous design we'll keep chewie's internal controls hidden
        showControls: false, 
        aspectRatio: videoPlayerController!.value.aspectRatio,
      );

      // Listeners
      videoPlayerController!.addListener(() {
        if (!videoPlayerController!.value.isInitialized) return;
        
        isPlaying.value = videoPlayerController!.value.isPlaying;
        isBuffering.value = videoPlayerController!.value.isBuffering;
        currentPosition.value = videoPlayerController!.value.position;
        totalDuration.value = videoPlayerController!.value.duration;

        if (videoPlayerController!.value.hasError) {
          _setError("Playback Error: ${videoPlayerController!.value.errorDescription}");
        }
      });

      isInitialized.value = true;
      isBuffering.value = false;

      if (autoRotate) _setFullScreen();
      resetHideTimer();
    } catch (e) {
      _setError("Native Setup Error: ${e.toString()}");
    }
  }

  // MARK: - Progress & Syncing

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (_) => syncWatchHistory());
  }

  Future<void> syncWatchHistory() async {
    if ((contentId == null && episodeId == null) || totalDuration.value.inSeconds < 1) return;
    try {
      final body = {
        "content_id": contentId,
        "episode_id": episodeId,
        "watch_position": currentPosition.value.inSeconds,
        "duration_seconds": totalDuration.value.inSeconds,
        "device_type": 'mobile',
      };
      await homeChopperService.syncWatchHistory(body);
    } catch (_) {}
  }

  // MARK: - User Interface Interactions
  void togglePlay() {
    resetHideTimer();
    if (videoSource.value == 'youtube') {
      isPlaying.value ? youtubeController?.pause() : youtubeController?.play();
    } else {
      isPlaying.value ? videoPlayerController?.pause() : videoPlayerController?.play();
    }
  }

  void seekTo(Duration pos) {
    videoSource.value == 'youtube' ? youtubeController?.seekTo(pos) : videoPlayerController?.seekTo(pos);
  }

  void seekForward10s() => seekTo(currentPosition.value + const Duration(seconds: 10));
  void seekBackward10s() => seekTo(currentPosition.value - const Duration(seconds: 10));

  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value) {
      resetHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void resetHideTimer() {
    _hideTimer?.cancel();
    if (showControls.value) {
      _hideTimer = Timer(const Duration(seconds: 3), () => showControls.value = false);
    }
  }

  void retry() => _loadPlaybackData();
  
  void _setError(String msg) {
    hasError.value = true;
    errorMessage.value = msg;
    isInitialized.value = true;
    showLoader(false);
  }

  Future<void> exitPlayer() async {
    try {
      syncWatchHistory();
      videoSource.value == 'youtube' ? youtubeController?.pause() : await videoPlayerController?.pause();
      if (autoRotate) _restoreScreen();
      await Future.delayed(const Duration(milliseconds: 150));
    } catch (_) {}
    Get.back();
  }
}
