import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Const/AppColors.dart';

/// Top bar with back button, drama title, EP count badge, and 1080P chip
class ReelTopBarWidget extends StatelessWidget {
  final VoidCallback onBack;
  final String dramaTitle;
  final int currentEpisode;
  final int totalEpisodes;

  const ReelTopBarWidget({
    super.key,
    required this.onBack,
    required this.dramaTitle,
    required this.currentEpisode,
    required this.totalEpisodes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Drama Title in header
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextWidget(
                  text: dramaTitle,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  maxLines: 1,
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.appColors,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: AppTextWidget(
                        text: "EP. $currentEpisode / $totalEpisodes",
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    AppTextWidget(
                      text: "HD 1080P",
                      fontSize: 10.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quality Tag Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.high_quality_rounded,
                  color: Colors.amberAccent,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                AppTextWidget(
                  text: "1080P",
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
