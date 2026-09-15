import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/Constants/AppExtension.dart';
import 'package:ottapp/Constants/AppNetworkSvg.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Widgets/AppPrimaryButton.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';

class BannerContentWidget extends StatelessWidget {
  final Items item;
  final VoidCallback? onPlay;

  const BannerContentWidget({super.key, required this.item, this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextWidget(
          text: item.title ?? "",
          color: AppColors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),

        SizedBox(height: 12.h),

        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10.w,
          runSpacing: 8.h,
          children: [
          item.rating !=null?  Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.grey[800],
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: AppTextWidget(
                text: item.rating ?? '',
                color: AppColors.white,
                fontSize: 12,
              ),
            ): SizedBox.shrink(),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (_) => Icon(Icons.star, color: AppColors.amber, size: 16.sp),
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppNetworkSvg(
                  url: "https://tr3bolplus.com/assets/images/pages/imdb-logo.svg",
                  width: 20.w,
                  height: 20.h,
                ),
                SizedBox(width: 10.w),
                AppTextWidget(
                  text: item.imdbRating ?? '',
                  color: AppColors.white,
                  fontSize: 12,
                ),
              ],
            ),

            item.durationMinutes != null
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    AppTextWidget(
                      text: item.durationMinutes?.toMovieDuration() ?? '',
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ],
                )
                : SizedBox.shrink(),
          ],
        ),

        SizedBox(height: 12.h),

        if (item.subtitle != null) ...[
          Flexible(
            child: AppTextWidget(

              text: item.subtitle ?? '',
              color: AppColors.white,
              fontSize: 12,
              maxLines: 5,
            ),
          ),
        ],

        SizedBox(height: 16.h),

        AppPrimaryButton(
          text: AppText.watchNow,
          onTap: () {
            if (onPlay != null) {
              onPlay!();
            } else {
              // Get.toNamed(RoutesName.infoScreen, arguments: item.contentUuid ?? item.uuid);
            }
          },
          icon: Icons.play_arrow,
          width: 140.w,
        ),
      ],
    );
  }
}
