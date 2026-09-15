

import 'package:flutter/material.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Controllers/HomeController.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:ottapp/Controllers/BaseController.dart';

class HorizontalRailWidget extends StatelessWidget {
  final Sections section;
  final VoidCallback? onLoadMore;
  const HorizontalRailWidget({super.key, required this.section, this.onLoadMore});

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
              if (section.hasMore == true)
                GestureDetector(
                  onTap: () => Get.toNamed(RoutesName.viewAllScreen, arguments: {
                    'pageSlug': Get.find<HomeController>().selectedPageSlug.value,
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
          height:  150.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: EdgeInsets.only(left: 10.w),
            itemBuilder: (context, index) {
              final item = items[index];
              if (index == items.length - 4 && section.hasMore == true && section.layoutType != AppText.top_10_rail) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onLoadMore?.call();
                });
              }
              return GestureDetector(
                onTap: () {
                  if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
                    Get.find<BaseController>().showLoginDialog();
                  } else {
                    Get.toNamed(RoutesName.infoScreen, arguments: item.contentUuid ?? item.uuid);
                  }
                },
                child: Container(
                  // color: AppColors.appColors,
                  width:  250.w,
                  margin: EdgeInsets.only(right: 15.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Stack(
                            children: [
                              AppNetworkImage(
                                imageUrl: item.poster??'',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                memCacheWidth: 600, // Optimize memory for horizontal banners
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.transparent,
                                      AppColors.black54,
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
                              if (section.slug == 'continue-watching' && item.watchProgress?.percent != null)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.white   .withAlpha(51),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: (item.watchProgress!.percent! / 100).clamp(0.0, 1.0),
                                      child: Container(
                                        color: AppColors.appColors,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                        SizedBox(height: 8.h),
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
            },
          ),
        ),
      ],
    );
  }
}