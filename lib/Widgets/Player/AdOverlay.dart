import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Controllers/AdBreakController.dart';
import 'package:video_player/video_player.dart';

/// Covers the player while an ad runs.
///
/// Deliberately has no scrubber: the controller owns the ad's timing and
/// refuses seeks, so there is nothing here for the viewer to drag. Skip only
/// appears when the creative allows it.
class AdOverlay extends StatelessWidget {
  const AdOverlay({super.key, required this.controller});

  final AdBreakController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.inAd.value) return const SizedBox.shrink();

      final player = controller.adPlayer.value;
      final ad = controller.currentBreak.value?.ad;

      return Positioned.fill(
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The creative. Tapping it counts as a click-through.
              if (player != null && player.value.isInitialized)
                GestureDetector(
                  onTap: controller.openAdvertiser,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: player.value.aspectRatio,
                      child: VideoPlayer(player),
                    ),
                  ),
                )
              else
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              // Top-left: what this is and how long is left.
              Positioned(
                top: 16.h,
                left: 16.w,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5B301),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        'Ad',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (controller.totalBreaks > 1)
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Text(
                          '${controller.adIndex.value} of ${controller.totalBreaks}',
                          style: _label,
                        ),
                      ),
                    Text('${controller.adRemaining.value}s', style: _label),
                    if (ad?.advertiser != null && ad!.advertiser!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Text('· ${ad.advertiser}', style: _label),
                      ),
                  ],
                ),
              ),

              // Bottom-right: visit and skip.
              Positioned(
                right: 16.w,
                bottom: 24.h,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ad?.clickUrl != null && ad!.clickUrl!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: _AdButton(
                          label: 'Visit advertiser',
                          icon: Icons.open_in_new,
                          onTap: controller.openAdvertiser,
                        ),
                      ),
                    if (controller.skipIn != null)
                      _AdButton(
                        label: controller.canSkip
                            ? 'Skip ad'
                            : 'Skip in ${controller.skipIn}',
                        icon: controller.canSkip ? Icons.skip_next : null,
                        filled: controller.canSkip,
                        onTap: controller.canSkip ? controller.skip : null,
                      ),
                  ],
                ),
              ),

              // Progress — display only, not interactive.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _AdProgress(controller: controller),
              ),
            ],
          ),
        ),
      );
    });
  }

  TextStyle get _label => TextStyle(
        color: Colors.white,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
      );
}

class _AdButton extends StatelessWidget {
  const _AdButton({
    required this.label,
    this.icon,
    this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.black : Colors.white;

    return Material(
      color: filled ? Colors.white : Colors.black.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(4.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: filled ? Colors.white : Colors.white.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (icon != null) ...[
                SizedBox(width: 6.w),
                Icon(icon, color: fg, size: 16.sp),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AdProgress extends StatelessWidget {
  const _AdProgress({required this.controller});

  final AdBreakController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final elapsed = controller.adElapsed.value;
      final total = elapsed + controller.adRemaining.value;
      final pct = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;

      return Container(
        height: 4.h,
        color: Colors.white.withValues(alpha: 0.25),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: pct,
          child: Container(color: const Color(0xFFF5B301)),
        ),
      );
    });
  }
}
