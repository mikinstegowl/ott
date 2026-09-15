import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Const/AppColors.dart';

/// Progress scrubber with interactive slider, timestamps, and play/pause button
class ReelProgressScrubber extends StatelessWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onTogglePlayPause;

  const ReelProgressScrubber({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
    required this.onSeek,
    required this.onTogglePlayPause,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final double progress = totalDuration.inMilliseconds > 0
        ? (currentPosition.inMilliseconds / totalDuration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: [
          // Progress bar track
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.5.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.r),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 10.r),
              activeTrackColor: AppColors.appColors,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: AppColors.appColors,
            ),
            child: Slider(
              value: progress,
              onChanged: (val) {
                final targetMillis = (val * totalDuration.inMilliseconds).toInt();
                onSeek(Duration(milliseconds: targetMillis));
              },
            ),
          ),

          // Timers with Play/Pause Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // GestureDetector(
                    //   onTap: onTogglePlayPause,
                    //   child: Icon(
                    //     isPlaying
                    //         ? Icons.pause_circle_filled_rounded
                    //         : Icons.play_circle_filled_rounded,
                    //     color: Colors.white,
                    //     size: 20.sp,
                    //   ),
                    // ),
                    SizedBox(width: 6.w),
                    AppTextWidget(
                      text: _formatDuration(currentPosition),
                      fontSize: 10,
                      color: Colors.white60,
                    ),
                  ],
                ),
                AppTextWidget(
                  text: _formatDuration(totalDuration),
                  fontSize: 10,
                  color: Colors.white60,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
