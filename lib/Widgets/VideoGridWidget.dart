import 'package:flutter/material.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Widgets/AppPrimaryButton.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:get/get.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:ottapp/Controllers/BaseController.dart';

class VideoGridWidget extends StatelessWidget {
  final Sections section;
  final VoidCallback? onLoadMore;
  const VideoGridWidget({super.key, required this.section, this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    final items = section.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: AppTextWidget(
            text: section.title ?? "",
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            maxLines: 1,
          ),
        ),
        SizedBox(height: 15.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Wrap(
            spacing: 15.w,
            runSpacing: 15.h,
            crossAxisAlignment: WrapCrossAlignment.start,
            children:
                items.map((item) {
                  final width = (MediaQuery.of(context).size.width - 40.w) / 2;
                  return VideoGridItem(
                    item: item,
                    width: width,
                    layoutType: section.layoutType,
                  );
                }).toList(),
          ),
        ),
        SizedBox(height: 30.h),
        if (section.hasMore == true)
          Center(
            child: AppPrimaryButton(
              text: AppText.load_more,
              onTap: () => onLoadMore?.call(),
              width: 180.w,
            ),
          ),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class VideoGridItem extends StatelessWidget {
  final Items item;
  final double width;
  final String? layoutType;

  const VideoGridItem({
    super.key,
    required this.item,
    required this.width,
    this.layoutType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
          Get.find<BaseController>().showLoginDialog();
        } else if (layoutType == AppText.shorts_grid ||
            layoutType == AppText.shorts_rail) {
          Get.toNamed(
            RoutesName.reelShortsScreen,
            arguments: {
              'uuid': item.contentUuid ?? item.uuid,
              'slug': item.slug,
              'dramaTitle': item.title,
              'item': item,
            },
          );
        } else {
          Get.toNamed(
            RoutesName.infoScreen,
            arguments: item.contentUuid ?? item.uuid,
          );
        }
      },
      child: Container(
        width: width,

        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Dark grey background
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster Image
            AspectRatio(
              aspectRatio: 2 / 3, // Standard movie poster ratio
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
                child: Stack(
                  children: [
                    AppNetworkImage(
                      imageUrl: item.thumbnail ?? '',
                      fit:   BoxFit.fill,
                      width: width,
                      height: double.infinity,
                    ),
                    /* 
                    if (item.isFree == false)
                      Positioned(
                        top: 5.h,
                        right: 5.w,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.appColors   .withAlpha(229),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black   .withAlpha(76),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    */
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.genres != null && item.genres!.isNotEmpty)
                    AppTextWidget(
                      text: item.genres!.join(", "),
                      color: AppColors.lightWhite70,
                      fontSize: 10,
                      maxLines: 1,
                    ),
                  SizedBox(height: 4.h),
                  AppTextWidget(
                    text: item.title ?? "",
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                  ),
                  if (item.subtitle != null) ...[
                    SizedBox(height: 4.h),
                    AppTextWidget(
                      text: item.subtitle!,
                      color: AppColors.white54,
                      fontSize: 10,
                      maxLines: 1,
                    ),
                  ],
                  // SizedBox(height: 12.h),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: AppPrimaryButton(
                  //         text: AppText.playNow,
                  //         onTap: () {
                  //           Get.toNamed(
                  //             RoutesName.infoScreen,
                  //             arguments: item.contentUuid ?? item.uuid,
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
