import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Const/AppColors.dart';

/// Bottom bar showing EP.X / EP.Y with up-arrow to open the episode drawer
class ReelEpisodeBarWidget extends StatelessWidget {
  final int currentEpisode;
  final int totalEpisodes;
  final VoidCallback onTap;

  const ReelEpisodeBarWidget({
    super.key,
    required this.currentEpisode,
    required this.totalEpisodes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTrailer = currentEpisode == 0;
    final String episodeLabel = isTrailer
        ? "Trailer / EP. $totalEpisodes"
        : "EP. $currentEpisode / EP. $totalEpisodes";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.appColors,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppTextWidget(
                  text: episodeLabel,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              AppTextWidget(
                text: "All Episodes",
                fontSize: 12,
                color: Colors.white54,
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
