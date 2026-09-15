import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Const/AppColors.dart';

/// Floating right vertical action column with Claim, Like, Save, Episodes, and Share
class ReelRightActionBar extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLikeTap;
  final bool isSaved;
  final int saveCount;
  final VoidCallback onSaveTap;
  final VoidCallback onClaimTap;
  final VoidCallback onEpisodesTap;
  final VoidCallback onShareTap;

  const ReelRightActionBar({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onLikeTap,
    required this.isSaved,
    required this.saveCount,
    required this.onSaveTap,
    required this.onClaimTap,
    required this.onEpisodesTap,
    required this.onShareTap,
  });

  String _formatCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w, bottom: 6.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. "Claim" Coin Reward Button
          // GestureDetector(
          //   onTap: onClaimTap,
          //   child: Column(
          //     children: [
          //       Container(
          //         width: 44.w,
          //         height: 44.h,
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           gradient: const RadialGradient(
          //             colors: [Color(0xFFFFDF00), Color(0xFFD4AF37)],
          //           ),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.amber.withValues(alpha: 0.45),
          //               blurRadius: 10,
          //               spreadRadius: 2,
          //             ),
          //           ],
          //         ),
          //         child: Center(
          //           child: Icon(
          //             Icons.monetization_on_rounded,
          //             color: const Color(0xFF5A3C00),
          //             size: 26.sp,
          //           ),
          //         ),
          //       ),
          //       SizedBox(height: 2.h),
          //       // Container(
          //       //   padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          //       //   decoration: BoxDecoration(
          //       //     color: const Color(0xFFFFB300),
          //       //     borderRadius: BorderRadius.circular(6.r),
          //       //   ),
          //       //   child: AppTextWidget(
          //       //     text: "Claim",
          //       //     fontSize: 9,
          //       //     fontWeight: FontWeight.bold,
          //       //     color: Colors.black,
          //       //   ),
          //       // ),
          //     ],
          //   ),
          // ),

          SizedBox(height: 18.h),

          // 2. Like Button
          GestureDetector(
            onTap: onLikeTap,
            child: Column(
              children: [
                Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? AppColors.appColors : Colors.white,
                  size: 32.sp,
                ),
                SizedBox(height: 2.h),
                AppTextWidget(
                  text: _formatCount(likeCount),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 3. Save / Bookmark Button
          GestureDetector(
            onTap: onSaveTap,
            child: Column(
              children: [
                Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.appColors : Colors.white,
                  size: 32.sp,
                ),
                SizedBox(height: 2.h),
                AppTextWidget(
                  text: _formatCount(saveCount),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 4. Episode List Quick Opener
          GestureDetector(
            onTap: onEpisodesTap,
            child: Column(
              children: [
                Icon(
                  Icons.video_library_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
                SizedBox(height: 2.h),
                AppTextWidget(
                  text: "Episodes",
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 5. Share / More Options
          GestureDetector(
            onTap: onShareTap,
            child: Column(
              children: [
                Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 26.sp,
                ),
                SizedBox(height: 2.h),
                AppTextWidget(
                  text: "Share",
                  fontSize: 10,
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
