import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Controllers/PlayerController.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppVideoPlayerView extends StatelessWidget {
  final PlayerController controller;
  final bool showHeader;
  final bool showProgress;
  final VoidCallback? onBack;

  const AppVideoPlayerView({
    super.key,
    required this.controller,
    this.showHeader = true,
    this.showProgress = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.hasError.value) return _buildErrorUI();
        if (!controller.isInitialized.value) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.appColors));
        }

        return GestureDetector(
          onTap: controller.toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: 'player-hero',
                  child: Center(
                    child: _buildPlayerSurface(),
                  ),
                ),
              ),

              // 2. Buffering Indicator
              Obx(() => controller.isBuffering.value
                  ? Center(
                      child:
                          CircularProgressIndicator(color: AppColors.appColors))
                  : const SizedBox.shrink()),

              // 3. Controls Overlay
              Obx(() => AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: controller.showControls.value ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !controller.showControls.value,
                      child: _buildControlsOverlay(context),
                    ),
                  )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPlayerSurface() {
    return Obx(() {
      if (controller.videoSource.value == 'youtube' &&
          controller.youtubeController != null) {
        return yt.YoutubePlayerBuilder(
          player: yt.YoutubePlayer(
            controller: controller.youtubeController!,
            showVideoProgressIndicator: false,
            topActions: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack ?? () => controller.exitPlayer(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.customTitle.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          builder: (context, player) => player,
        );
      } else if (controller.chewieController.value != null) {
        return SizedBox.expand(
          child: Chewie(
            controller: controller.chewieController.value!,
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildControlsOverlay(BuildContext context) {
    return Stack(
      children: [
        // Top Bar
        if (showHeader)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black   .withAlpha(178), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: onBack ?? () => controller.exitPlayer(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.customTitle.value,
                      style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Center Actions
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlBtn(Icons.replay_10, controller.seekBackward10s, size: 40),
              const SizedBox(width: 40),
              _buildControlBtn(
                controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                controller.togglePlay,
                size: 80,
              ),
              const SizedBox(width: 40),
              _buildControlBtn(Icons.forward_10, controller.seekForward10s, size: 40),
            ],
          ),
        ),

        // Bottom Progress Bar
        if (showProgress)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black   .withAlpha(178), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      activeTrackColor: AppColors.appColors,
                      thumbColor: AppColors.appColors,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: controller.currentPosition.value.inSeconds.toDouble().clamp(
                        0.0,
                        controller.totalDuration.value.inSeconds.toDouble() > 0 
                          ? controller.totalDuration.value.inSeconds.toDouble() 
                          : 1.0,
                      ),
                      max: controller.totalDuration.value.inSeconds.toDouble() > 0 
                        ? controller.totalDuration.value.inSeconds.toDouble() 
                        : (controller.currentPosition.value.inSeconds.toDouble() > 0 
                            ? controller.currentPosition.value.inSeconds.toDouble() 
                            : 1.0),
                      onChanged: (v) => controller.seekTo(Duration(seconds: v.toInt())),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDur(controller.currentPosition.value), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(_formatDur(controller.totalDuration.value), style: const TextStyle(color: Colors.white70, fontSize: 12)),
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

  Widget _buildControlBtn(IconData icon, VoidCallback onTap, {double size = 30}) {
    return IconButton(
      iconSize: size,
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
    );
  }

  Widget _buildErrorUI() {
    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 16,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: onBack ?? () => controller.exitPlayer(),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.appColors, size: 60),
              const SizedBox(height: 16),
              Text(controller.errorMessage.value, style: TextStyle(color: AppColors.white)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDur(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    if (d.inHours > 0) return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }
}
