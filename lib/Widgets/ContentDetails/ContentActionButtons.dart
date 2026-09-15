import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Widgets/AppPrimaryButton.dart';

class ContentActionButtons extends StatelessWidget {
  final String playText;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isInWatchlist;
  final bool isLoading;
  final bool isPlayLoading;

  const ContentActionButtons({
    super.key,
    this.playText = "Watch Now",
    this.onPlay,
    this.onFavorite,
    this.onShare,
    this.isInWatchlist = false,
    this.isLoading = false,
    this.isPlayLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              text: playText,
              onTap: onPlay ?? () {},
              icon: Icons.play_arrow,
              isLoading: isPlayLoading,
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildIconButton(
                isInWatchlist ? Icons.favorite : Icons.favorite_border, 
                onFavorite,
                iconColor: isInWatchlist ? AppColors.appColors : AppColors.white,
                isLoading: isLoading,
                text: "Watchlist",
              ),
              SizedBox(width: 30.w),
              _buildIconButton(
                Icons.share,
                onShare,
                iconColor: AppColors.white,
                text: "Share",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap, {Color? iconColor, bool isLoading = false, String? text}) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white10,
              shape: BoxShape.circle,
            ),
            child: isLoading 
              ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.appColors,
                  ),
                )
              : Icon(icon, color: iconColor ?? AppColors.white, size: 20.sp),
          ),
          if (text != null) ...[
            SizedBox(height: 5.h),
            Text(
              text,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

