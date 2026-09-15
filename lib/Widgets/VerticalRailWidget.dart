import 'package:flutter/material.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:ottapp/Controllers/HomeController.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:get/get.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:ottapp/Controllers/BaseController.dart';

class VerticalRailWidget extends StatelessWidget {
  final Sections section;
  final VoidCallback? onLoadMore;
  const VerticalRailWidget({super.key, required this.section, this.onLoadMore});

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppTextWidget(
                  text: section.title ?? "",
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                ),
              ),
              if (section.layoutType != 'top_10_rail')
                GestureDetector(
                  onTap: () => Get.toNamed(RoutesName.viewAllScreen, arguments: {
                    'pageSlug': Get.find<HomeController>().selectedPageSlug.value, // Need to pass pageSlug properly
                    'sectionSlug': section.slug ?? '',
                    'title': section.title ?? '',
                  }),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                      child: AppTextWidget(
                        text: "View All",
                        color: AppColors.appColors,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height:  250.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: EdgeInsets.only(left: 10.w),
            itemBuilder: (context, index) {
              final item = items[index];
              return VerticalRailItem(
                item: item,
                section: section,
                index: index,
                onLoadMore: () {
                  if (index == items.length - 4 &&
                      section.hasMore == true &&
                      section.layoutType != AppText.top_10_rail) {
                    onLoadMore?.call();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
class VerticalRailItem extends StatelessWidget {
  final Items item;
  final Sections section;
  final int index;
  final VoidCallback? onLoadMore;
  final double? width;
  final BoxFit? fit;

  const VerticalRailItem({
    super.key,
    required this.item,
     this.fit,
    required this.section,
    required this.index,
    this.onLoadMore,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (onLoadMore != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onLoadMore?.call();
      });
    }

    return
      GestureDetector(
      onTap: () {
        if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
          Get.find<BaseController>().showLoginDialog();
        } else if (item.item_type == 'shorts' ||
            item.contentType == 'Short Series' ||
            item.contentType == 'shorts' ||
            section.layoutType == AppText.shorts_rail ||
            section.layoutType == AppText.shorts_grid) {
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
        width: width ?? 170.w,
        margin: width == null ? EdgeInsets.only(right: 10.w) : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13.r),
                child: Stack(
                  children: [
                    AppNetworkImage(
                      imageUrl: item.thumbnail  ?? '',
                      fit: fit ?? BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      memCacheWidth: 400, // Optimize memory for lists
                    ),
                    if (item.item_type == 'shorts' || item.contentType == 'Short Series')
                      Positioned(
                        top: 8.h,
                        left: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.appColors.withAlpha(220),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            "SHORTS",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (section.slug == 'top-10-movies')
                    Container(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.transparent,
                            AppColors.blackOpacity60,
                          ],
                        ),
                      ),
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
                    if (section.slug == 'top-10-movies')
                      Positioned(
                        top: 140.h,
                        right: 5.w,
                        bottom: 0.h,
                        child: AppTextWidget(
                          text: "${index + 1}",
                          color: AppColors.whiteOpacity80,
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 8.h),
            // AppTextWidget(
            //   text: item.title ?? "",
            //   color: AppColors.white,
            //   fontSize: 12,
            //   fontWeight: FontWeight.w500,
            //   maxLines: 1,
            // ),
          ],
        ),
      ),
    );
  }
}
