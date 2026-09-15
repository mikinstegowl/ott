import 'package:flutter/material.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/Constants/AppExtension.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:ottapp/Constants/AppNetworkSvg.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Widgets/AppPrimaryButton.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:ottapp/Controllers/BaseController.dart';

class SingleSpotlightWidget extends StatefulWidget {
  final Sections section;

  const SingleSpotlightWidget({super.key, required this.section});

  @override
  State<SingleSpotlightWidget> createState() => _SingleSpotlightWidgetState();
}

class _SingleSpotlightWidgetState extends State<SingleSpotlightWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.section.items == null || widget.section.items!.isEmpty) {
      return const SizedBox.shrink();
    }


    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 600.h,
          margin: EdgeInsets.symmetric(vertical: 20.h),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.section.items?.length,
                onPageChanged: (index) {
                },
                itemBuilder: (context, index) {
                  final item = widget.section.items![index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Parallax Background Image Effect
                      Opacity(
                        opacity: 0.2,
                        child: AppNetworkImage(
                          imageUrl:  item.thumbnail ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),


                      // Content Layer (Centered as per user's latest design)
                      GestureDetector(
                        onTap: () {
                          if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
                            Get.find<BaseController>().showLoginDialog();
                          } else {
                            Get.toNamed(RoutesName.infoScreen, arguments: item.contentUuid ?? item.uuid);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppNetworkImage(
                              imageUrl: item.thumbnail ?? '',
                              fit: BoxFit.cover,
                              height: 300,
                              width: 250,
                            ),
                            SizedBox(height: 20.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title
                                AppTextWidget(
                                  text: item.title ?? "",
                                  color: AppColors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 10.h),
    
                                // Rating, IMDb, Duration Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Stars
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          Icons.star,
                                          color: AppColors.amber,
                                          size: 14.sp,
                                        );
                                      }),
                                    ),
                                    SizedBox(width: 8.w),
                                    // Rating value
                                    AppTextWidget(
                                      text: item.imdbRating ?? "0.0",
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    SizedBox(width: 8.w),
                                    // IMDb Logo
                                    AppNetworkSvg(
                                      url: "https://tr3bolplus.com/assets/images/pages/imdb-logo.svg",
                                      width: 20.w,
                                      height: 20.h,
                                    ),
                                    SizedBox(width: 15.w),
                                    // Duration
                                    if (item.durationMinutes != null) ...[
                                      Icon(Icons.access_time, color: AppColors.lightWhite70, size: 14.sp),
                                      SizedBox(width: 4.w),
                                      AppTextWidget(
                                        text: item.durationMinutes?.toMovieDuration() ?? '0',
                                        color: AppColors.lightWhite70,
                                        fontSize: 12,
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 15.h),
                                // Subtitle / Type & Year
                                AppTextWidget(
                                  text: "${item.contentType ?? 'Movie'} • ${item.releaseYear ?? ''}",
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                SizedBox(height: 8.h),
    
                                // Description
                                AppTextWidget(
                                  text: item.shortDescription ?? "",
                                  color: AppColors.lightWhite70,
                                  fontSize: 12,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 15.h),
    
                                // Play Now Button
                                AppPrimaryButton(
                                  text: AppText.playNow,
                                  onTap: () {
                                    if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
                                      Get.find<BaseController>().showLoginDialog();
                                    } else {
                                      Get.toNamed(RoutesName.infoScreen, arguments: item.contentUuid ?? item.uuid);
                                    }
                                  },
                                  icon: Icons.play_arrow,
                                  width: 140.w,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}



