import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Network/AppChopperClient.dart';
import 'package:ottapp/Models/GeneralErrorModel.dart';
import 'package:ottapp/Models/MagicLinkModel.dart';
import 'package:ottapp/Models/ShortDramaModel.dart';
import 'package:ottapp/Models/ShortsProgressModel.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:ottapp/Constants/ShareHelper.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:ottapp/Widgets/InAppPurchase/InAppPurchaseBottomSheet.dart';

/// ReelShortsController - Business logic and state management for Vertical Reels / Drama Player
class ReelShortsController extends BaseController {
  final HomeChopperService homeChopperService;

  ReelShortsController({HomeChopperService? chopperService})
      : homeChopperService =
            chopperService ?? AppChopperClient().getChopperService<HomeChopperService>();

  // Instagram-like vertical PageController for scrolling reels
  late PageController pageController;

  // Video Player & Playback State
  VideoPlayerController? videoPlayerController;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isPlaying = false.obs;
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxBool isLoadingVideo = false.obs;
  final RxBool hasVideoError = false.obs;
  final RxString videoErrorMessage = "".obs;

  // Lock state for current episode
  final RxBool isCurrentEpisodeLocked = false.obs;
  final RxString lockedMessage = "".obs;
  final RxString lastErrorCode = "".obs;
  final RxString lastMsgHeader = "".obs;
  final RxString lastMsgDesc = "".obs;
  final RxString lastMsgBtn = "".obs;
  MagicLinkModel? magicLinkModel;

  // Track completion to avoid duplicate next-episode triggers
  bool _hasCompletedCurrentEpisode = false;

  // Flag indicating smooth auto-advance page animation is in progress
  bool _isAutoAdvancing = false;

  // Controls Visibility & Timers
  final RxBool showControls = true.obs;
  Timer? _hideControlsTimer;
  Timer? _syncProgressTimer;

  // Drama API Data & Metadata
  final RxString dramaSlug = "".obs;
  final RxString dramaUuid = "".obs;
  final Rx<ShortDramaData?> dramaData = Rxn<ShortDramaData>();
  final RxList<ShortEpisodeItem> episodesList = <ShortEpisodeItem>[].obs;
  final Rx<ShortEpisodeItem?> currentEpisodeItem = Rxn<ShortEpisodeItem>();
  final RxBool isLoadingDrama = false.obs;

  final RxString dramaTitle = "".obs;
  final RxString synopsis = "".obs;
  final RxList<String> tags = <String>[].obs;
  final RxList<Map<String, String>> cast = <Map<String, String>>[
    {"name": "Eric Guilmette", "role": "Eli Baran"},
    {"name": "Nikki Leigh", "role": "Christine"},
    {"name": "Kyle Glenn", "role": "Billionaire"},
    {"name": "Raina Silve", "role": "Elena"},
  ].obs;

  // Episode Configuration
  final RxInt totalEpisodes = 1.obs;
  final RxInt currentEpisode = 1.obs;
  final RxSet<int> unlockedEpisodes = <int>{1}.obs;

  int get effectiveTotalEpisodes {
    final eps = episodesList.length;
    if (totalEpisodes.value > 0) {
      return totalEpisodes.value >= eps ? totalEpisodes.value : eps;
    }
    return eps > 0 ? eps : 1;
  }

  // Interactions State
  final RxBool isLiked = false.obs;
  final RxInt likeCount = 0.obs;
  final RxBool isSaved = false.obs;
  final RxInt saveCount = 0.obs;
  final RxInt userCoins = 50.obs;
  final RxBool isSynopsisExpanded = false.obs;

  // Fallback demo video stream if stream URL is unavailable
  static const String fallbackVideoUrl =
      "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_5MB.mp4";

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      dramaSlug.value = (args['slug'] ?? args['slug_name']) as String? ?? "";
      dramaUuid.value = (args['uuid'] ?? args['contentUuid']) as String? ?? "";
      final String? passedTitle =
          (args['dramaTitle'] ?? args['title'] ?? args['name']) as String?;
      if (passedTitle != null && passedTitle.isNotEmpty) {
        dramaTitle.value = passedTitle;
      }
      final int? passedEpisode = args['episode'] as int?;
      if (passedEpisode != null && passedEpisode > 0) {
        currentEpisode.value = passedEpisode;
      }
    } else if (args is String && args.isNotEmpty) {
      if (args.contains('-')) {
        dramaSlug.value = args;
      } else {
        dramaTitle.value = args;
      }
    }

    if (dramaSlug.value.isEmpty) {
      dramaSlug.value = "bory-verticale";
    }

    pageController = PageController(
      initialPage: (currentEpisode.value - 1).clamp(0, 9999),
    );

    fetchDramaDetails(dramaSlug.value);
    startHideControlsTimer();
    _startPeriodicProgressSync();
  }

  /// PageView swiped (Instagram Reels vertical scroll)
  void onPageSwiped(int index) {
    if (_isAutoAdvancing) return;
    final newEpNumber = index + 1;
    if (currentEpisode.value != newEpNumber) {
      debugPrint("ReelShortsController: Swiped to Episode $newEpNumber");
      if (!isCurrentEpisodeLocked.value) {
        syncWatchProgress();
      }
      selectEpisode(newEpNumber, updatePageController: false);
    }
  }

  /// Fetch Drama metadata and episodes list from /shorts/{slug}
  Future<void> fetchDramaDetails(String slug) async {
    try {
      isLoadingDrama.value = true;
      final response = await homeChopperService.getShortDramaDetailAPI(slug);

      if (response.isSuccessful && response.body?.data != null) {
        final data = response.body?.data;
        dramaData.value = data;

        if (data?.title != null && (data?.title?.isNotEmpty ?? false)) {
          dramaTitle.value = data?.title ?? "";
        }
        synopsis.value = data?.description ?? data?.shortDescription ?? "";

        if (data?.tags != null && (data?.tags?.isNotEmpty ?? false)) {
          tags.value = data?.tags ?? [];
        } else if (data?.genres != null && (data?.genres?.isNotEmpty ?? false)) {
          tags.value = data?.genres ?? [];
        }

        likeCount.value = data?.likeCount ?? 0;
        isLiked.value = data?.isLiked ?? false;
        isSaved.value = data?.isBookmarked ?? false;
        saveCount.value = data?.bookmarkCount ?? 0;

        final eps = data?.episodes ?? [];
        episodesList.assignAll(eps);
        totalEpisodes.value = data?.totalEpisodes ?? eps.length;

        final unlocked = <int>{};
        for (final ep in eps) {
          if (ep.isFree == true || ep.isLocked == false) {
            final num = ep.episodeNumber;
            if (num != null) unlocked.add(num);
          }
        }
        if (unlocked.isNotEmpty) {
          unlockedEpisodes.assignAll(unlocked);
        }

        // Find initial episode to play
        ShortEpisodeItem? targetEp;
        for (final ep in eps) {
          if (ep.episodeNumber == currentEpisode.value) {
            targetEp = ep;
            break;
          }
        }
        if (targetEp == null && eps.isNotEmpty) {
          targetEp = eps.first;
        }

        if (targetEp != null) {
          currentEpisodeItem.value = targetEp;
          currentEpisode.value = targetEp.episodeNumber ?? 1;
          isLiked.value = targetEp.isLiked ?? data?.isLiked ?? false;
          likeCount.value = targetEp.likeCount ?? data?.likeCount ?? 0;
          final epUuid = targetEp.uuid;
          if (epUuid != null && epUuid.isNotEmpty) {
            playEpisodeByUuid(epUuid);
          }
        }
      } else {
        await initVideoPlayer(url: fallbackVideoUrl);
      }
    } catch (e) {
      debugPrint("ReelShortsController fetchDramaDetails error: $e");
      await initVideoPlayer(url: fallbackVideoUrl);
    } finally {
      isLoadingDrama.value = false;
    }
  }

  /// Fetch magic link from auth/magic-link to obtain subscription URL
  Future<String?> fetchMagicLinkUrl() async {
    try {
      final response = await homeChopperService.magicLinkAPI(
        Platform.isIOS ? 'ios' : 'android',
      );
      if (response.isSuccessful && response.body?.data?.magicUrl != null) {
        magicLinkModel = response.body;
        return response.body!.data!.magicUrl;
      }
    } catch (e) {
      debugPrint("ReelShortsController fetchMagicLinkUrl error: $e");
    }
    return null;
  }

  /// Show In-App Purchase sheet directly when an episode is members only / requires subscription
  Future<void> showSubscriptionRequiredDialog({
    String? title,
    String? description,
    String? buttonText,
  }) async {
    if (isClosed) return;
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    final context = Get.context;
    if (context != null) {
      InAppPurchaseBottomSheet.show(context);
    }
  }

  /// Request playback stream URL from /shorts/episodes/{uuid}/play
  Future<void> playEpisodeByUuid(String episodeUuid) async {
    try {
      isLoadingVideo.value = true;
      hasVideoError.value = false;
      videoErrorMessage.value = "";
      isCurrentEpisodeLocked.value = false;

      final response = await homeChopperService.playShortEpisodeAPI(episodeUuid);

      final playData = response.body?.data;
      final videoUrls = playData?.videoUrls;
      final streamUrl = videoUrls?.master ??
          videoUrls?.p1080 ??
          videoUrls?.p720 ??
          videoUrls?.p360 ??
          playData?.watchUrl;

      if (response.isSuccessful && streamUrl != null && streamUrl.isNotEmpty) {
        if (currentEpisodeItem.value?.uuid != episodeUuid) {
          return;
        }
        lastErrorCode.value = "";
        isCurrentEpisodeLocked.value = false;
        await initVideoPlayer(url: streamUrl);
      } else {
        if (currentEpisodeItem.value?.uuid != episodeUuid) {
          return;
        }

        // Fully detach and dispose video controller to prevent progress increments or audio leaks
        final old = videoPlayerController;
        videoPlayerController = null;
        await old?.pause();
        await old?.dispose();

        isVideoInitialized.value = false;
        isPlaying.value = false;
        currentPosition.value = Duration.zero;
        totalDuration.value = Duration.zero;

        // Extract error payload
        String? code = response.body?.code;
        String? msg = response.body?.message;
        String? msgHeader = response.body?.msgHeader;
        String? msgDesc = response.body?.msgDesc;
        String? msgBtn = response.body?.msgBtn;

        if (response.error != null) {
          if (response.error is GeneralErrorModel) {
            final err = response.error as GeneralErrorModel;
            code ??= err.errorCode ?? err.code?.toString();
            msg ??= err.message;
            msgHeader ??= err.msgHeader;
            msgDesc ??= err.msgDesc;
            msgBtn ??= err.msgBtn;
          } else if (response.error is Map) {
            final errMap = response.error as Map;
            code ??= errMap['code']?.toString();
            msg ??= errMap['message']?.toString();
            msgHeader ??= errMap['msg_header']?.toString();
            msgDesc ??= errMap['msg_desc']?.toString();
            msgBtn ??= errMap['msg_btn']?.toString();
          } else if (response.error is String) {
            try {
              final decoded = jsonDecode(response.error as String);
              if (decoded is Map) {
                code ??= decoded['code']?.toString();
                msg ??= decoded['message']?.toString();
                msgHeader ??= decoded['msg_header']?.toString();
                msgDesc ??= decoded['msg_desc']?.toString();
                msgBtn ??= decoded['msg_btn']?.toString();
              }
            } catch (_) {}
          }
        }

        final finalDesc = msgDesc ?? msg ?? "This episode isn't included with your current account.";
        final finalHeader = msgHeader ?? "Members Only";
        final finalBtn = msgBtn ?? "Manage Account";

        lastErrorCode.value = code ?? "";
        lastMsgHeader.value = finalHeader;
        lastMsgDesc.value = finalDesc;
        lastMsgBtn.value = finalBtn;

        isCurrentEpisodeLocked.value = true;
        lockedMessage.value = finalDesc;

        final isSubRequired = code == "SUBSCRIPTION_REQUIRED" ||
            (msg != null && msg.contains("included with your current account")) ||
            (msgDesc != null && msgDesc.contains("included with your current account"));

        if (isSubRequired) {
          await showSubscriptionRequiredDialog(
            title: finalHeader,
            description: finalDesc,
            buttonText: finalBtn,
          );
        } else if (code == "LOGIN_REQUIRED" || response.statusCode == 401 || response.statusCode == 403) {
          if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
            Get.find<BaseController>().showLoginDialog();
          }
        } else {
          hasVideoError.value = true;
          videoErrorMessage.value = finalDesc;
        }
      }
    } catch (e) {
      debugPrint("ReelShortsController playEpisodeByUuid error: $e");
      hasVideoError.value = true;
      videoErrorMessage.value = e.toString();
    } finally {
      isLoadingVideo.value = false;
    }
  }

  /// Initialize video player instance
  Future<void> initVideoPlayer({String? url}) async {
    final videoUrl = url ?? fallbackVideoUrl;

    try {
      final oldController = videoPlayerController;
      videoPlayerController = null;
      await oldController?.pause();
      await oldController?.dispose();

      isVideoInitialized.value = false;
      _hasCompletedCurrentEpisode = false;

      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      videoPlayerController = controller;

      await controller.initialize();
      controller.setLooping(false);
      await controller.play();

      controller.addListener(() {
        if (videoPlayerController == controller) {
          currentPosition.value = controller.value.position;
          totalDuration.value = controller.value.duration;

          final bool isCurrentlyPlaying = controller.value.isPlaying;
          if (isPlaying.value != isCurrentlyPlaying) {
            isPlaying.value = isCurrentlyPlaying;
            if (isCurrentlyPlaying) {
              startHideControlsTimer();
            } else {
              showControls.value = true;
              _hideControlsTimer?.cancel();
            }
          }

          // Automatic next episode playback when video finishes
          final duration = controller.value.duration;
          final position = controller.value.position;
          final isEnded = controller.value.isCompleted ||
              (duration > Duration.zero && position >= duration);

          if (isEnded && !_hasCompletedCurrentEpisode) {
            _hasCompletedCurrentEpisode = true;
            debugPrint(
              "ReelShortsController: Episode ${currentEpisode.value} completed. Auto-playing next episode!",
            );
            syncWatchProgress();
            playNextEpisode();
          }
        }
      });

      isVideoInitialized.value = true;
      isPlaying.value = true;
      showControls.value = true;
      startHideControlsTimer();
    } catch (e) {
      debugPrint("ReelShortsController Video Player initialization error: $e");
    }
  }

  /// Automatically advance to next episode like reels with smooth 450ms easeOutCubic curve
  Future<void> playNextEpisode() async {
    final nextEpNumber = currentEpisode.value + 1;
    final hasNext = episodesList.any((e) => e.episodeNumber == nextEpNumber) ||
        nextEpNumber <= effectiveTotalEpisodes;

    if (hasNext) {
      if (pageController.hasClients) {
        _isAutoAdvancing = true;
        // Pause current video so audio doesn't spill over during swipe
        await videoPlayerController?.pause();
        await pageController.animateToPage(
          nextEpNumber - 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
        _isAutoAdvancing = false;
        selectEpisode(nextEpNumber, updatePageController: false);
      } else {
        selectEpisode(nextEpNumber);
      }
    } else {
      // Reached end of series - loop playback like reels without blocking gestures
      videoPlayerController?.seekTo(Duration.zero);
      videoPlayerController?.play();
      _hasCompletedCurrentEpisode = false;
    }
  }

  /// Go to previous episode with smooth reel transition
  Future<void> playPreviousEpisode() async {
    final prevEpNumber = currentEpisode.value - 1;
    if (prevEpNumber >= 1) {
      if (pageController.hasClients) {
        _isAutoAdvancing = true;
        await videoPlayerController?.pause();
        await pageController.animateToPage(
          prevEpNumber - 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
        _isAutoAdvancing = false;
        selectEpisode(prevEpNumber, updatePageController: false);
      } else {
        selectEpisode(prevEpNumber);
      }
    }
  }

  /// Start auto-hide timer (5 seconds) for overlay controls
  void startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (isPlaying.value && !isCurrentEpisodeLocked.value) {
        showControls.value = false;
      }
    });
  }

  /// Toggle playback and controls on screen tap (standard reel behavior)
  void toggleControlsAndPlayback() {
    if (isCurrentEpisodeLocked.value) {
      return;
    }
    togglePlayPause();
  }

  /// Play / Pause toggle
  void togglePlayPause() {
    final player = videoPlayerController;
    if (player != null && isVideoInitialized.value) {
      if (player.value.isPlaying) {
        player.pause();
        isPlaying.value = false;
        showControls.value = true;
        _hideControlsTimer?.cancel();
      } else {
        player.play();
        isPlaying.value = true;
        startHideControlsTimer();
      }
    } else {
      isPlaying.value = !isPlaying.value;
      if (!isPlaying.value) {
        showControls.value = true;
        _hideControlsTimer?.cancel();
      } else {
        startHideControlsTimer();
      }
    }
  }

  /// Seek video position
  void seekTo(Duration position) {
    videoPlayerController?.seekTo(position);
    currentPosition.value = position;
    startHideControlsTimer();
  }

  /// Toggle Like with backend API sync (per episode)
  Future<void> toggleLike() async {
    if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
      Get.find<BaseController>().showLoginDialog();
      return;
    }

    final newStatus = !isLiked.value;
    isLiked.value = newStatus;
    likeCount.value += newStatus ? 1 : -1;
    if (likeCount.value < 0) likeCount.value = 0;

    // Update active episode item in episodesList
    final currentEp = currentEpisodeItem.value;
    if (currentEp != null) {
      currentEp.isLiked = newStatus;
      currentEp.likeCount = likeCount.value;
    }

    final epUuid = currentEp?.uuid;

    try {
      if (epUuid != null && epUuid.isNotEmpty) {
        if (newStatus) {
          await homeChopperService.likeShortEpisodeAPI(epUuid);
        } else {
          await homeChopperService.unlikeShortEpisodeAPI(epUuid);
        }
      }
    } catch (e) {
      debugPrint("toggleLike error: $e");
    }
  }

  /// Toggle Save / Bookmark with backend API sync
  Future<void> toggleSave() async {
    if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
      Get.find<BaseController>().showLoginDialog();
      return;
    }

    final newStatus = !isSaved.value;
    isSaved.value = newStatus;
    saveCount.value += newStatus ? 1 : -1;
    if (saveCount.value < 0) saveCount.value = 0;

    Get.snackbar(
      isSaved.value ? "Saved to My List" : "Removed from My List",
      isSaved.value ? "You can resume watching anytime" : "",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );

    try {
      if (newStatus) {
        await homeChopperService.bookmarkShortAPI(dramaSlug.value);
      } else {
        await homeChopperService.unbookmarkShortAPI(dramaSlug.value);
      }
    } catch (e) {
      debugPrint("toggleSave error: $e");
    }
  }

  /// Claim Coins Reward
  void claimCoins(int amount) {
    userCoins.value += amount;
  }

  /// Open Social Sharing Dialog with backend API share data
  void shareDrama() {
    Share? shareData = dramaData.value?.share;
    final fallbackDesc = synopsis.value.isNotEmpty
        ? synopsis.value
        : (dramaData.value?.description ?? dramaData.value?.shortDescription ?? "");

    if (shareData == null) {
      final String url = "https://trebolplus.com/shorts/${dramaSlug.value}";
      shareData = Share(
        url: url,
        title: dramaTitle.value,
        description: fallbackDesc,
        image: dramaData.value?.verticalPoster ?? dramaData.value?.coverImage,
      );
    } else if (shareData.description == null || shareData.description!.isEmpty) {
      shareData = Share(
        url: shareData.url ?? "https://trebolplus.com/shorts/${dramaSlug.value}",
        title: shareData.title ?? dramaTitle.value,
        description: fallbackDesc,
        image: shareData.image ?? dramaData.value?.verticalPoster ?? dramaData.value?.coverImage,
      );
    }

    ShareHelper.shareNative(shareData: shareData);
  }

  /// Expand / Collapse synopsis text
  void toggleSynopsisExpanded() {
    isSynopsisExpanded.value = !isSynopsisExpanded.value;
    startHideControlsTimer();
  }

  /// Select an episode to play
  void selectEpisode(int epNumber, {bool updatePageController = true}) {
    _hasCompletedCurrentEpisode = false;
    currentEpisode.value = epNumber;
    isCurrentEpisodeLocked.value = false;
    currentPosition.value = Duration.zero;
    totalDuration.value = Duration.zero;
    isPlaying.value = false;
    showControls.value = true;

    // Dispose and detach old video player immediately so it doesn't leak listeners or audio
    final old = videoPlayerController;
    videoPlayerController = null;
    old?.pause();
    old?.dispose();
    isVideoInitialized.value = false;

    if (updatePageController && pageController.hasClients) {
      final targetPage = epNumber - 1;
      if (pageController.page?.round() != targetPage) {
        pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    }

    ShortEpisodeItem? target;
    for (final ep in episodesList) {
      if (ep.episodeNumber == epNumber) {
        target = ep;
        break;
      }
    }

    if (target != null) {
      currentEpisodeItem.value = target;
      isLiked.value = target.isLiked ?? false;
      likeCount.value = target.likeCount ?? 0;
      final uuid = target.uuid;
      if (uuid != null && uuid.isNotEmpty) {
        playEpisodeByUuid(uuid);
        return;
      }
    }
    initVideoPlayer();
  }

  /// Unlock episode with coins or ad
  void unlockEpisode(int epNumber, int updatedCoins) {
    unlockedEpisodes.add(epNumber);
    userCoins.value = updatedCoins;
    selectEpisode(epNumber);
  }

  /// Progress syncing timer (runs every 10 seconds)
  void _startPeriodicProgressSync() {
    _syncProgressTimer?.cancel();
    _syncProgressTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => syncWatchProgress(),
    );
  }

  /// Sync watch progress with backend /shorts/progress using model
  Future<void> syncWatchProgress() async {
    // If current episode is locked, never sync progress!
    if (isCurrentEpisodeLocked.value) return;

    final ep = currentEpisodeItem.value;
    final epUuid = ep?.uuid;
    if (epUuid == null || epUuid.isEmpty) return;
    if (totalDuration.value.inSeconds < 1) return;

    try {
      final request = ShortsProgressRequestModel(
        episodeUuid: epUuid,
        positionSeconds: currentPosition.value.inSeconds,
        durationSeconds: totalDuration.value.inSeconds,
      );
      final response = await homeChopperService.syncShortProgress(request);
      if (response.isSuccessful) {
        debugPrint(
          "ReelShortsController: Progress synced for Ep ${currentEpisode.value} (${currentPosition.value.inSeconds}s / ${totalDuration.value.inSeconds}s)",
        );
      } else {
        debugPrint(
          "ReelShortsController: Progress sync error ${response.statusCode}: ${response.error}",
        );
      }
    } catch (e) {
      debugPrint("ReelShortsController syncWatchProgress error: $e");
    }
  }

  @override
  void onClose() {
    _syncProgressTimer?.cancel();
    _hideControlsTimer?.cancel();
    if (!isCurrentEpisodeLocked.value) {
      syncWatchProgress();
    }
    videoPlayerController?.dispose();
    pageController.dispose();
    super.onClose();
  }
}