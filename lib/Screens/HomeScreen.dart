import 'package:flutter/material.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/Constants/AppLoader.dart';
import 'package:ottapp/Controllers/HomeController.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Widgets/HeroBanner/HeroBannerWidget.dart';
import 'package:ottapp/Widgets/HorizontalRailWidget.dart';
import 'package:ottapp/Widgets/VerticalRailWidget.dart';
import 'package:ottapp/Widgets/GenreRailWidget.dart';
import 'package:ottapp/Widgets/VideoGridWidget.dart';
import 'package:ottapp/Widgets/SingleSpotlightWidget.dart';
import 'package:ottapp/Widgets/CustomAppBar.dart';
import 'package:ottapp/Router/RouterName.dart';

import 'package:ottapp/Widgets/SponsorRailWidget.dart';

import 'package:ottapp/Widgets/SectionSkeleton.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppColors.black,
      drawer: Drawer(
        backgroundColor: AppColors.black,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Image.asset('assets/image/logo.png', height: 100.h),
              ),
              Obx(() {
                final data =
                    controller.profileData.value?.data ??
                    controller.planName.value?.data;
                final name = data?.name ?? "User";
                final email = data?.email ?? "user@example.com";
                final initial =
                    name.isNotEmpty
                        ? name.trim().substring(0, 1).toUpperCase()
                        : "U";
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ).copyWith(bottom: 10.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundColor: AppColors.appColors.withAlpha(51),
                        foregroundImage:
                            (data?.avatar != null && data!.avatar!.isNotEmpty)
                                ? NetworkImage(data.avatar!)
                                : null,
                        child: AppTextWidget(
                          text: initial,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appColors,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextWidget(
                              text: name,
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(height: 2.h),
                            AppTextWidget(
                              text: email,
                              color: AppColors.grey500,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 10.h),
              Divider(color: AppColors.white10),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: controller.menus.length,
                    itemBuilder: (context, index) {
                      final menu = controller.menus[index];
                      final isSelected =
                          controller.selectedPageSlug.value == menu.slug;
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                        leading: Icon(
                          Icons.movie_filter_rounded,
                          color:
                              isSelected
                                  ? AppColors.appColors
                                  : AppColors.white54,
                          size: 20.sp,
                        ),
                        title: AppTextWidget(
                          text: menu.title ?? "",
                          color:
                              isSelected
                                  ? AppColors.appColors
                                  : AppColors.white,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onTap: () {
                          Get.back(); // Close drawer
                          controller.getHomeData(slug: menu.slug);
                        },
                      );
                    },
                  ),
                ),
              ),
              Divider(color: AppColors.white10),
              // ListTile(
              //   leading: Icon(
              //     Icons.favorite_rounded,
              //     color: AppColors.white54,
              //     size: 20.sp,
              //   ),
              //   title: const AppTextWidget(
              //     text: "Reel Shorts",
              //     color: AppColors.white,
              //     fontSize: 14,
              //     fontWeight: FontWeight.normal,
              //   ),
              //   onTap: () {
              //     Get.back();
              //     // Get.toNamed(RoutesName.reelShortsScreen);
              //     controller.getHomeData(slug: 'shorts');
              //   },
              // ),
              ListTile(
                leading: Icon(
                  Icons.favorite_rounded,
                  color: AppColors.white54,
                  size: 20.sp,
                ),
                title: const AppTextWidget(
                  text: "My Watchlist",
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                onTap: () {
                  Get.back();
                  Get.toNamed(RoutesName.watchlistScreen);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.white54,
                  size: 20.sp,
                ),
                title: const AppTextWidget(
                  text: "FAQ",
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                onTap: () async {
                  Get.back();
                  final Uri url = Uri.parse('https://trebolplus.com/faq');
                  if (!await launchUrl(url)) {
                    debugPrint('Could not launch $url');
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.white54,
                  size: 20.sp,
                ),
                title: const AppTextWidget(
                  text: "Support",
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                onTap: () {
                  Get.back();
                  controller.supportAction();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.red),
                title: const AppTextWidget(
                  text: "Logout",
                  color: AppColors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                onTap: () => controller.logOut(),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.red,
                ),
                title: const AppTextWidget(
                  text: "Delete Account",
                  color: AppColors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                onTap: () => controller.deleteAccount(),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      appBar: CustomAppBar(scaffoldKey: controller.scaffoldKey),
      body: Obx(() {
        if (controller.isLoading.value && controller.homeModel.value == null) {
          return const Center(child: AppLoader());
        }

        final sections = controller.homeModel.value?.data?.sections ?? [];

        return RefreshIndicator(
          onRefresh: controller.getHomeData,
          color: AppColors.appColors,
          child: CustomScrollView(
            key: ValueKey(controller.selectedPageSlug.value),
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverList.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  Widget sectionWidget;
                  switch (section.layoutType) {
                    case AppText.hero_banner:
                      sectionWidget = HeroBannerWidget(
                        section: section,
                        onLoadMore: () => controller.loadMoreItems(section),
                      );
                      break;
                    case AppText.horizontal_rail:
                    case AppText.landscape_rail:
                      sectionWidget = HorizontalRailWidget(
                        section: section,
                        onLoadMore: () => controller.loadMoreItems(section),
                      );
                      break;
                    case AppText.shorts_rail:
                    case AppText.top_10_rail:
                    case AppText.vertical_rail:
                    case AppText.banner_card:
                    case AppText.portrait_rail:
                      sectionWidget = VerticalRailWidget(
                        section: section,
                        onLoadMore: () => controller.loadMoreItems(section),
                      );
                      break;
                    case AppText.genre_tabs:
                      sectionWidget = GenreRailWidget(
                        section: section,
                        data: controller.getAllGenreModel.value?.data ?? [],
                        onLoadMore: () => controller.loadMoreItems(section),
                      );
                      break;

                    case AppText.shorts_grid:
                    case AppText.vertical_grid:
                      sectionWidget = VideoGridWidget(
                        section: section,
                        onLoadMore: () => controller.loadMoreItems(section),
                      );
                      break;
                    case AppText.single_spotlight:
                      sectionWidget = SingleSpotlightWidget(section: section);
                      break;
                    case AppText.sponsor_rail:
                      sectionWidget = SponsorRailWidget(section: section);
                      break;

                    default:
                      sectionWidget = const SizedBox.shrink();
                  }
                  return sectionWidget;
                },
              ),
              if (controller.isMoreSectionsLoading.value)
                const SliverToBoxAdapter(child: SectionSkeleton()),
              SliverToBoxAdapter(child: SizedBox(height: 40.h)),
              if (controller.isLoading.value)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: AppLoader()),
                ),
            ],
          ),
        );
      }),
    );
  }
}
