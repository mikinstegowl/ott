import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Models/ShortDramaModel.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Controllers/ReelShortsController.dart';
import 'package:ottapp/Widgets/ReelShorts/ReelCenterPlayButton.dart';
import 'package:ottapp/Widgets/ReelShorts/ReelTopBarWidget.dart';
import 'package:ottapp/Widgets/ReelShorts/ReelProgressScrubber.dart';
import 'package:ottapp/Widgets/ReelShorts/ReelEpisodeBarWidget.dart';
import 'package:ottapp/Widgets/ReelShorts/ReelBottomInfoWidget.dart';
import 'package:ottapp/Widgets/ReelShorts/ReelRightActionBar.dart';
import 'package:ottapp/Widgets/ReelShorts/EpisodeSelectionBottomSheet.dart';
import 'package:ottapp/Widgets/ReelShorts/ReelModals.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// ReelShortsScreen - Instagram Reel-like Vertical Scrolling Micro-Drama Player
class ReelShortsScreen extends GetView<ReelShortsController> {
  const ReelShortsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fullscreen Instagram Reel-like Vertical PageView
          Obx(
            () => ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              child: PageView.builder(
                controller: controller.pageController,
                scrollDirection: Axis.vertical,
                physics: const PageScrollPhysics(
                  parent: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                ),
                itemCount: controller.effectiveTotalEpisodes,
                onPageChanged: controller.onPageSwiped,
                itemBuilder: (context, index) {
                  final epNumber = index + 1;
                  return _EpisodeCardView(
                    epNumber: epNumber,
                    controller: controller,
                    onOpenEpisodeSheet: () => _openEpisodeSheet(context),
                  );
                },
              ),
            ),
          ),

          // 2. Persistent Top Bar pinned at top (Height is small, does not block vertical swipes)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Obx(() {
                final bool showTopBar = controller.isCurrentEpisodeLocked.value ||
                    controller.showControls.value;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showTopBar ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !showTopBar,
                    child: ReelTopBarWidget(
                      onBack: () => Get.back(),
                      dramaTitle: controller.dramaTitle.value,
                      currentEpisode: controller.currentEpisode.value,
                      totalEpisodes: controller.effectiveTotalEpisodes,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _openEpisodeSheet(BuildContext context) {
    EpisodeSelectionBottomSheet.show(
      context: context,
      dramaTitle: controller.dramaTitle.value,
      posterUrl: controller.dramaData.value?.verticalPoster ??
          controller.dramaData.value?.coverImage,
      totalEpisodes: controller.effectiveTotalEpisodes,
      currentEpisode: controller.currentEpisode.value,
      unlockedEpisodes: controller.unlockedEpisodes,
      episodes: controller.episodesList,
      userCoins: controller.userCoins.value,
      onSelectEpisode: controller.selectEpisode,
      onEpisodeUnlocked: controller.unlockEpisode,
    );
  }
}

/// Each Reel Card containing the video, backdrop, and its own metadata/actions
class _EpisodeCardView extends StatelessWidget {
  final int epNumber;
  final ReelShortsController controller;
  final VoidCallback onOpenEpisodeSheet;

  const _EpisodeCardView({
    required this.epNumber,
    required this.controller,
    required this.onOpenEpisodeSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isCurrent = epNumber == controller.currentEpisode.value;
      final bool areControlsVisible = !isCurrent ||
          controller.isCurrentEpisodeLocked.value ||
          controller.showControls.value;

      ShortEpisodeItem? epItem;
      for (final e in controller.episodesList) {
        if (e.episodeNumber == epNumber) {
          epItem = e;
          break;
        }
      }

      final posterUrl = epItem?.thumbnail ??
          controller.dramaData.value?.verticalPoster ??
          controller.dramaData.value?.coverImage;

      return Stack(
        fit: StackFit.expand,
        children: [
          // A. Video Layer / Backdrop / Locked View
          if (isCurrent && controller.isCurrentEpisodeLocked.value)
            _buildLockedView(context, epNumber, posterUrl)
          else if (isCurrent &&
              controller.isVideoInitialized.value &&
              controller.videoPlayerController != null)
            _buildActiveVideoPlayer(controller.videoPlayerController)
          else
            _buildBackdrop(posterUrl, epNumber, isCurrent),

          // B. Gradient Vignettes for Readability (Passes touches through)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: areControlsVisible ? 1.0 : 0.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.90),
                      ],
                      stops: const [0.0, 0.16, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // C. Tap Gesture Detector for toggling controls and double-tap to like
          // Translucent behavior lets vertical drag pass to PageView immediately!
          if (!controller.isCurrentEpisodeLocked.value)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: controller.toggleControlsAndPlayback,
                onDoubleTap: controller.toggleLike,
                child: const SizedBox.expand(),
              ),
            ),

          // D. Dead-Center Play/Pause Button (Appears when paused or when controls are active)
          if (!controller.isCurrentEpisodeLocked.value)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: (isCurrent && (!controller.isPlaying.value || controller.showControls.value))
                  ? 1.0
                  : 0.0,
              child: IgnorePointer(
                ignoring: !isCurrent ||
                    (controller.isPlaying.value && !controller.showControls.value),
                child: Center(
                  child: ReelCenterPlayButton(
                    isPlaying: controller.isPlaying.value,
                    onTap: controller.togglePlayPause,
                  ),
                ),
              ),
            ),

          // E. Bottom Information & Controls (Attached to card, scrolls fluidly with the reel!)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: true,
              minimum: EdgeInsets.only(bottom: 12.h),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: areControlsVisible ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !areControlsVisible,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lower Info Row: Left Metadata + Right Action Bar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left: Drama Metadata & Synopsis
                      Expanded(
                        child: ReelBottomInfoWidget(
                          dramaTitle: controller.dramaTitle.value,
                          synopsis: epItem?.description ??
                              (controller.synopsis.value.isNotEmpty
                                  ? controller.synopsis.value
                                  : (controller.dramaData.value?.description ??
                                      controller.dramaData.value?.shortDescription ??
                                      "")),
                          tags: controller.tags,
                          isSynopsisExpanded:
                              controller.isSynopsisExpanded.value,
                          onTapTitle: () {
                            ReelModals.showDramaDetailsModal(
                              context,
                              dramaTitle: controller.dramaTitle.value,
                              synopsis: epItem?.description ??
                                  controller.synopsis.value,
                              tags: controller.tags,
                              cast: controller.cast,
                              currentEpisode: epNumber,
                            );
                          },
                          onToggleSynopsis: controller.toggleSynopsisExpanded,
                        ),
                      ),

                      // Right: Floating Action Bar (Claim, Like, Save, Episodes, Share)
                        ReelRightActionBar(
                        isLiked: isCurrent ? controller.isLiked.value : (epItem?.isLiked ?? false),
                        likeCount: isCurrent ? controller.likeCount.value : (epItem?.likeCount ?? 0),
                        onLikeTap: controller.toggleLike,
                        isSaved: controller.isSaved.value,
                        saveCount: controller.saveCount.value,
                        onSaveTap: controller.toggleSave,
                        onClaimTap: () {
                          ReelModals.showClaimRewardDialog(
                            context,
                            onClaim: () => controller.claimCoins(20),
                          );
                        },
                        onEpisodesTap: onOpenEpisodeSheet,
                        onShareTap: controller.shareDrama,
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Video Progress Scrubber (Only visible and interactive for unlocked, playable episodes)
                  if (isCurrent && !controller.isCurrentEpisodeLocked.value) ...[
                    ReelProgressScrubber(
                      currentPosition: controller.currentPosition.value,
                      totalDuration: controller.totalDuration.value,
                      isPlaying: controller.isPlaying.value,
                      onSeek: controller.seekTo,
                      onTogglePlayPause: controller.togglePlayPause,
                    ),
                    SizedBox(height: 8.h),
                  ],

                  // Bottom Episode Drawer Bar
                  ReelEpisodeBarWidget(
                    currentEpisode: epNumber,
                    totalEpisodes: controller.effectiveTotalEpisodes,
                    onTap: onOpenEpisodeSheet,
                  ),

                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),
        ),
      ),
        ],
      );
    });
  }

  /// Active video player widget fitted fullscreen with cover
  Widget _buildActiveVideoPlayer(VideoPlayerController? player) {
    if (player == null) return const SizedBox.shrink();
    final size = player.value.size;
    final double width = size.width > 0 ? size.width : 1080;
    final double height = size.height > 0 ? size.height : 1920;

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: width,
        height: height,
        child: VideoPlayer(player),
      ),
    );
  }

  /// Swiping / loading backdrop displaying poster and primary green spinner
  Widget _buildBackdrop(String? posterUrl, int epNumber, bool isCurrent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (posterUrl != null && posterUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: posterUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.black),
            errorWidget: (_, __, ___) => Container(color: Colors.black),
          )
        else
          Container(color: Colors.black),
        Container(
          color: Colors.black.withValues(alpha: 0.40),
        ),
        if (isCurrent && controller.isLoadingVideo.value)
          Center(
            child: SizedBox(
              width: 38.w,
              height: 38.w,
              child: const CircularProgressIndicator(
                strokeWidth: 3.2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.appColors),
              ),
            ),
          ),
      ],
    );
  }

  /// Locked episode overlay with brand green accents
  Widget _buildLockedView(
    BuildContext context,
    int epNumber,
    String? posterUrl,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (posterUrl != null && posterUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: posterUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.black),
            errorWidget: (_, __, ___) => Container(color: Colors.black),
          )
        else
          Container(color: Colors.black),
        Container(
          color: Colors.black.withValues(alpha: 0.88),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand Green Lock Circle
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.appColors.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.appColors,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 46.sp,
                    color: AppColors.appColors,
                  ),
                ),
                SizedBox(height: 20.h),
                AppTextWidget(
                  text: "Episode $epNumber",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                AppTextWidget(
                  text: controller.lockedMessage.value.isNotEmpty
                      ? controller.lockedMessage.value
                      : "Please sign in or unlock to watch this episode.",
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColors,
                    foregroundColor: Colors.black,
                    padding:
                        EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    if (controller.lastErrorCode.value == "SUBSCRIPTION_REQUIRED") {
                      controller.showSubscriptionRequiredDialog();
                    } else {
                      onOpenEpisodeSheet();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.lastErrorCode.value == "SUBSCRIPTION_REQUIRED"
                            ? Icons.workspace_premium_rounded
                            : Icons.lock_open_rounded,
                        size: 20.sp,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8.w),
                      AppTextWidget(
                        text: controller.lastErrorCode.value == "SUBSCRIPTION_REQUIRED"
                            ? (controller.lastMsgBtn.value.isNotEmpty
                                ? controller.lastMsgBtn.value
                                : "Manage Account")
                            : "Unlock Episode",
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
