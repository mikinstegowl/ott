import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Constants/AppExtension.dart';
import 'package:ottapp/Constants/AppNetworkSvg.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';

class ContentMetadata extends StatelessWidget {
  final String? releaseYear;
  final int? durationMinutes;
  final int? viewCount;
  final String? imdbRating;
  final List<String>? genres;
  final String? language;

  const ContentMetadata({
    super.key,
    this.releaseYear,
    this.durationMinutes,
    this.viewCount,
    this.imdbRating,
    this.genres,
    this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (releaseYear != null) ...[
                _buildMetaItem(releaseYear??""),
                _buildDot(),
              ],
              if (durationMinutes != null) ...[
                _buildMetaWithIcon(Icons.access_time, durationMinutes!.toMovieDuration()),
                _buildDot(),
              ],
              _buildMetaWithIcon(Icons.remove_red_eye_outlined, "${viewCount ?? 0} Views"),
              _buildDot(),
              AppTextWidget(
                text: "${imdbRating ?? "0.0"} ",
                color: AppColors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(width: 4.w),
              AppNetworkSvg(
                url: "https://tr3bolplus.com/assets/images/pages/imdb-logo.svg",
                width: 20.w,
                height: 20.h,
              ),
            ],
          ),
        ),
        if (genres != null && (genres?.isNotEmpty ?? false)) ...[
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.movie_outlined, color: AppColors.lightWhite70, size: 16.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: AppTextWidget(
                  text: genres!.join(", "),
                  color: AppColors.lightWhite70,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
        if (language != null) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.translate, color: AppColors.lightWhite70, size: 16.sp),
              SizedBox(width: 8.w),
              AppTextWidget(
                text: language!,
                color: AppColors.lightWhite70,
                fontSize: 14.sp,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMetaItem(String text) {
    return AppTextWidget(
      text: text,
      color: AppColors.white,
      fontSize: 14.sp,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildMetaWithIcon(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.lightWhite70, size: 16.sp),
        SizedBox(width: 4.w),
        AppTextWidget(
          text: text,
          color: AppColors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Icon(Icons.circle, size: 4.sp, color: AppColors.lightWhite70),
    );
  }
}
