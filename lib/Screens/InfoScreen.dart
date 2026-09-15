import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Constants/AppLoader.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:ottapp/Controllers/InfoController.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Widgets/ContentDetails/ContentDetailView.dart';
import 'package:ottapp/Models/InfoModel.dart';

class InfoScreen extends GetView<InfoController> {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        toolbarHeight: 35.h,
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppColors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: AppLoader());
        }

        final data = controller.contentData.value;
        if (data == null) {
          return Center(
            child: AppTextWidget(
              text: "Content not found",
              color: AppColors.white,
            ),
          );
        }

        return ContentDetailView(
          data: data.data,
          isLoading: false,
          showVideo: controller.showVideo.value,
          isDescriptionExpanded: controller.isDescriptionExpanded.value,
          trailerUrl: controller.fullTrailerUrl.value,
          onToggleDescription: controller.toggleDescription,
          playText: controller.watchNowText.value,
          onPlay: controller.watchNowAction,
          onFavorite: controller.toggleWatchlist,
          onShare: controller.shareContent,
          isLoadingWatchlist: controller.isTogglingWatchlist.value,
          isPlayLoading: controller.isPlayingContent.value,
          extraSection: Column(
            children: [
              _buildEpisodesSection(),
              _buildRecommendedSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEpisodesSection() {
    return Obx(() {
      final seasons = controller.contentData.value?.data?.seasons ?? [];
      final episodes = controller.episodes;
      final isTvSeries = controller.contentData.value?.data?.contentType == 'series';

      if (!isTvSeries || seasons.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: AppTextWidget(
              text: "Episodes",
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          _buildSeasonSelector(seasons),
          SizedBox(height: 15.h),
          if (controller.isLoadingEpisodes.value)
            const Center(child: AppLoader())
          else if (episodes.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: AppTextWidget(
                  text: "No episodes available",
                  color: AppColors.white   .withAlpha(127),
                ),
              ),
            )
          else
            SizedBox(
              height: 180.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final episode = episodes[index];
                  return Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: () => controller.playEpisode(episode),
                      child: Container(
                        width: 280.w,
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
                                      imageUrl: episode.thumbnail ?? '',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    if (episode.durationMinutes != null)
                                      Positioned(
                                        top: 8.h,
                                        right: 8.w,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: AppColors.blackOpacity60,
                                            borderRadius: BorderRadius.circular(4.r),
                                          ),
                                          child: AppTextWidget(
                                            text: "${episode.durationMinutes} min",
                                            color: AppColors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            AppTextWidget(
                              text: "E${episode.episodeNumber} : ${episode.title ?? ''}",
                              color: AppColors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }

  Widget _buildSeasonSelector(List<Seasons> seasons) {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        itemBuilder: (context, index) {
          final season = seasons[index];
          final isSelected = controller.selectedSeason.value?.id == season.id;
          return Material(
            color: AppColors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () => controller.onSeasonChanged(season),
              child: Container(
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.green : AppColors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.green : AppColors.whiteOpacity30,
                  ),
                ),
                child: Center(
                  child: AppTextWidget(
                    text: season.title ?? "Season ${season.seasonNumber}",
                    color: AppColors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedSection({final VoidCallback? onLoadMore}) {
    return Obx(() {
      final recommendedItems = controller.recommendedData.value?.data ?? [];

      if (recommendedItems.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: AppTextWidget(
              text: "Recommended",
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(
            height:  300.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendedItems.length,
              itemBuilder: (context, index) {
                final item = recommendedItems[index];
                // final item = items[index];
                if (index == recommendedItems.length - 4) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onLoadMore?.call();
                  });
                }
                return
                //   Material(
                //   color: AppColors.transparent,
                //   child: InkWell(
                //     borderRadius: BorderRadius.circular(8.r),
                //     onTap: () {
                //       if (item.uuid != null) {
                //         Get.offNamed(
                //           RoutesName.infoScreen,
                //           arguments: item.uuid,
                //           preventDuplicates: false,
                //         );
                //       }
                //     },
                //     child: Container(
                //       width: 120.w,
                //       margin: EdgeInsets.only(right: 12.w),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Expanded(
                //             child: ClipRRect(
                //               borderRadius: BorderRadius.circular(8.r),
                //               child: AppNetworkImage(
                //                 imageUrl: item.thumbnail ?? '',
                //                 fit: BoxFit.cover,
                //                 width: 120.w,
                //               ),
                //             ),
                //           ),
                //           SizedBox(height: 8.h),
                //           // AppTextWidget(
                //           //   text: item.title ?? "",
                //           //   color: AppColors.white,
                //           //   fontSize: 12,
                //           //   maxLines: 1,
                //           // ),
                //         ],
                //       ),
                //     ),
                //   ),
                // );
                  Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap:
                          () => Get.offNamed(
                        RoutesName.infoScreen,
                        arguments:  item.uuid,
                            preventDuplicates: false
                      ),
                      child: Container(
                        width: 200.w,
                        margin: EdgeInsets.only(right: 15.w) ,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Stack(
                                  children: [
                                    AppNetworkImage(
                                      imageUrl:  item.thumbnail ?? '',
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                      memCacheWidth: 400, // Optimize memory for lists
                                    ),
                                    // if (section.slug == 'top-10-movies')
                                    //   Container(
                                    //     height: double.maxFinite,
                                    //     width: double.maxFinite,
                                    //     decoration: BoxDecoration(
                                    //       gradient: LinearGradient(
                                    //         begin: Alignment.centerLeft,
                                    //         end: Alignment.bottomCenter,
                                    //         colors: [
                                    //           AppColors.transparent,
                                    //           AppColors.blackOpacity60,
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ),
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
                                    // if (section.slug == 'top-10-movies')
                                    //   Positioned(
                                    //     top: 140.h,
                                    //     right: 5.w,
                                    //     bottom: 0.h,
                                    //     child: AppTextWidget(
                                    //       text: "${index + 1}",
                                    //       color: AppColors.whiteOpacity80,
                                    //       fontSize: 80,
                                    //       fontWeight: FontWeight.w900,
                                    //     ),
                                    //   ),
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
                    ),
                  );
              },
            ),
          ),
          SizedBox(height: 50.h),
        ],
      );
    });
  }
}
