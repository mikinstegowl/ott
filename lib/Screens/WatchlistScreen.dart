import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Constants/AppLoader.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:ottapp/Controllers/WatchlistController.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Models/ShortsListModel.dart';

class WatchlistScreen extends GetView<WatchlistController> {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Get.back(),
          ),
          title: AppTextWidget(
            text: "My Watchlist",
            color: AppColors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  indicator: BoxDecoration(
                    color: AppColors.appColors,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  labelColor: AppColors.black,
                  unselectedLabelColor: AppColors.whiteOpacity80,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  onTap: (index) {
                    controller.selectedTab.value = index;
                    index == 0 ? controller.fetchWatchlist(): controller.fetchShortlist();
                  },
                  tabs: const [
                    Tab(text: "Movies"),
                    Tab(text: "Shorts"),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildMoviesTab(),
            _buildShortsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoviesTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.watchlistItems.isEmpty) {
        return const Center(child: AppLoader());
      }

      if (controller.watchlistItems.isEmpty) {
        return _buildEmptyState(
          icon: Icons.favorite_border,
          title: "Your watchlist is empty",
          subtitle: "Add movies and series to watch them later",
        );
      }

      return _buildWatchlistGrid();
    });
  }

  Widget _buildShortsTab() {
    return Obx(() {
      if (controller.shortsWatchlistItems.isEmpty) {
        return _buildEmptyState(
          icon: Icons.video_collection_outlined,
          title: "Your shorts watchlist is empty",
          subtitle: "Add shorts and reels to watch them later",
        );
      }

      return _buildShortsGrid();
    });
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80.sp, color: AppColors.whiteOpacity30),
          SizedBox(height: 20.h),
          AppTextWidget(
            text: title,
            color: AppColors.whiteOpacity50,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 10.h),
          AppTextWidget(
            text: subtitle,
            color: AppColors.grey500,
            fontSize: 14.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistGrid() {
    return RefreshIndicator(
      onRefresh: controller.fetchWatchlist,
      color: AppColors.appColors,
      backgroundColor: AppColors.grey800,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(15.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 15.h,
                crossAxisSpacing: 15.w,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = controller.watchlistItems[index];
                  return _buildWatchlistItem(item);
                },
                childCount: controller.watchlistItems.length,
              ),
            ),
          ),
          if (controller.isLoadingMore.value)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(child: AppLoader()),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  Widget _buildShortsGrid() {
    return CustomScrollView(
      controller: controller.shortsScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(15.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              mainAxisSpacing: 15.h,
              crossAxisSpacing: 15.w,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = controller.shortsWatchlistItems[index];
                return _buildShortsItem(item);
              },
              childCount: controller.shortsWatchlistItems.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 40.h)),
      ],
    );
  }

  Widget _buildWatchlistItem(dynamic item) {
    final content = item.content;
    return GestureDetector(
      onTap: () => controller.goToDetails(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: AppNetworkImage(
                    imageUrl: content.thumbnail  ?? '',
                    fit:  BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    memCacheWidth: 400, // Optimize memory for lists
                  ),
                ),
                // "Movie/Series" Tag overlay
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.appColors.withAlpha(229),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: AppTextWidget(
                      text: (content?.contentType ?? 'Movie').toUpperCase(),
                      color: AppColors.black,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(height: 10.h),
          // AppTextWidget(
          //   text: content?.title ?? '',
          //   color: AppColors.white,
          //   fontSize: 14.sp,
          //   fontWeight: FontWeight.w600,
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          // ),
          // if (content?.releaseYear != null)
          //   AppTextWidget(
          //     text: content!.releaseYear!,
          //     color: AppColors.grey500,
          //     fontSize: 12.sp,
          //   ),
        ],
      ),
    );
  }

  Widget _buildShortsItem(Data item) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          RoutesName.reelShortsScreen,
          arguments: {
            'uuid': item.uuid ?? item,
            'slug': item.slug,
            'dramaTitle': item.title,
            'item': item,
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: AppNetworkImage(
                    imageUrl: item.verticalPoster  ?? '',
                    fit:  BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    memCacheWidth: 400, // Optimize memory for lists
                  ),
                ),
                // "SHORTS" Tag overlay
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.appColors.withAlpha(229),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, size: 12.sp, color: AppColors.black),
                        SizedBox(width: 2.w),
                        AppTextWidget(
                          text: "SHORTS",
                          color: AppColors.black,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(height: 10.h),
          // AppTextWidget(
          //   text: item.title ??  '',
          //   color: AppColors.white,
          //   fontSize: 14.sp,
          //   fontWeight: FontWeight.w600,
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          // ),
        ],
      ),
    );
  }
}
