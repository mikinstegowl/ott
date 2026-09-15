import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Controllers/SearchController.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:ottapp/Widgets/VerticalRailWidget.dart';
import 'package:ottapp/Models/HomeModel.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MySearchController>();
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(controller),
                _buildFilterChips(controller),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && !controller.isLoadingMore.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.isSearching.value) {
                      return _buildSearchResults(controller);
                    } else {
                      return _buildBrowseByGenre(controller);
                    }
                  }),
                ),
              ],
            ),
            _buildSuggestionsOverlay(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(MySearchController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white10,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 12.w),
            Icon(Icons.search, color: AppColors.white54, size: 20.sp),
            SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: controller.searchFieldController,
                    onChanged: controller.onSearchTextChanged,
                    onSubmitted: (v) => controller.performSearch(),
                    style: TextStyle(color: AppColors.white, fontSize: 15.sp),
                    decoration: InputDecoration(
                      hintText: "Search movies, series, shorts...",
                      hintStyle: TextStyle(color: AppColors.whiteOpacity30, fontSize: 13.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
            Obx(() {
              if (controller.isSuggestionsLoading.value) {
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: SizedBox(
                    width: 15.w,
                    height: 15.w,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.appColors),
                  ),
                );
              }
              return controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: AppColors.white54, size: 18.sp),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(MySearchController controller) {
    return Obx(() {
      if (controller.contentTypes.isEmpty) return const SizedBox.shrink();
      return Container(
        height: 50.h,
        padding: EdgeInsets.only(bottom: 8.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: controller.contentTypes.length + (controller.selectedType.value != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.contentTypes.length) {
              final type = controller.contentTypes[index];
              return Obx(() {
                final isSelected = controller.selectedType.value?.slug == type.slug;
                return Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: () => controller.onTypeSelected(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.appColors : AppColors.white10,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color: isSelected ? AppColors.appColors : AppColors.white12,
                          width: 1.5,
                        ),
                        boxShadow: isSelected? [
                          BoxShadow(
                            color: AppColors.appColors   .withAlpha(76),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                      child: Center(
                        child: AppTextWidget(
                          text: type.name ?? "",
                          color: isSelected ? Colors.black : AppColors.whiteOpacity80,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              });
            } else {
              // The "Clear Filter" button at the end
              return Center(
                child: TextButton(
                  onPressed: controller.clearFilters,
                  child: AppTextWidget(
                    text: "Clear Filter",
                    color: AppColors.appColors,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
          },
        ),
      );
    });
  }

  Widget _buildBrowseByGenre(MySearchController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: AppTextWidget(
            text: "Browse by Genre",
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Obx(() => GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: controller.genres.length,
            itemBuilder: (context, index) {
              final genre = controller.genres[index];
              return GestureDetector(
                onTap: () => controller.onGenreSelected(genre),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(
                        imageUrl: genre.thumbnail ?? "",
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black   .withAlpha(102),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: AppTextWidget(
                            text: genre.name ?? "",
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
        ),
      ],
    );
  }

  Widget _buildSearchResults(MySearchController controller) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Row(
                    children: [
                      AppTextWidget(
                        text: "${controller.searchResults.length} Results Found",
                        color: AppColors.white54,
                        fontSize: 14,
                      ),
                      if (controller.selectedGenre.value != null) ...[
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: controller.clearSearch,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.appColors.withAlpha(30),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: AppColors.appColors.withAlpha(100)),
                            ),
                            child: Row(
                              children: [
                                AppTextWidget(
                                  text: controller.selectedGenre.value!.name ?? "Clear",
                                  color: AppColors.appColors,
                                  fontSize: 12,
                                ),
                                SizedBox(width: 4.w),
                                Icon(Icons.close, size: 12.sp, color: AppColors.appColors),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  )),
              _buildSortDropdown(controller),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.searchResults.isEmpty) {
              return Center(
                child: AppTextWidget(
                  text: "No results found",
                  color: AppColors.white54,
                  fontSize: 16,
                ),
              );
            }
            return GridView.builder(
              controller: controller.scrollController,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65, // Taller cells for larger-looking 'contain' images
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
              ),
              itemCount: controller.searchResults.length + (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.searchResults.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final item = controller.searchResults[index];
                return
                  VerticalRailItem(
                  item: item,
                  section: Sections(slug: 'search_results', title: 'Search Results'),
                  index: index,
                  fit: BoxFit.contain,
                  width: double.infinity,
                                  );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSortDropdown(MySearchController controller) {
    return PopupMenuButton<String>(
      onSelected: controller.onSortChanged,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      itemBuilder: (context) => [
        _buildPopupItem(controller, "Most Popular", "popularity"),
        _buildPopupItem(controller, "Top Rated", "rating"),
        _buildPopupItem(controller, "Newest", "release_date"),
        _buildPopupItem(controller, "A - Z", "title"),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.white10,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Obx(() {
              String label = "Sort by";
              if (controller.currentSort.value == "popularity") label = "Most Popular";
              if (controller.currentSort.value == "top_rated") label = "Top Rated";
              if (controller.currentSort.value == "release_date") label = "Newest";
              if (controller.currentSort.value == "title") label = "A - Z";
              return AppTextWidget(text: label, color: AppColors.white, fontSize: 12);
            }),
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down, color: AppColors.white54, size: 18.sp),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(MySearchController controller, String label, String value) {
    return PopupMenuItem(
      value: value,
      child: Obx(() => AppTextWidget(
            text: label,
            color: controller.currentSort.value == value ? AppColors.appColors : AppColors.lightWhite70,
            fontSize: 14,
          )),
    );
  }

  Widget _buildSuggestionsOverlay(MySearchController controller) {
    return Obx(() {
      if (!controller.showSuggestions.value || controller.suggestions.isEmpty) {
        return const SizedBox.shrink();
      }
      return Positioned(
        top: 80.h,
        left: 16.w,
        right: 16.w,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(12.r),
          color: const Color(0xFF1E1E1E),
          child: Container(
            constraints: BoxConstraints(maxHeight: 400.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.white12, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(127),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contents / Movies section
                    if (controller.contentSuggestions.isNotEmpty) ...[
                      _buildSuggestionSectionHeader("MOVIES & SERIES"),
                      for (int i = 0; i < controller.contentSuggestions.length; i++) ...[
                        if (i > 0) Divider(color: AppColors.white10, height: 1),
                        _buildSuggestionTile(
                          controller,
                          controller.contentSuggestions[i],
                          isShort: false,
                        ),
                      ],
                    ],

                    // Shorts section
                    if (controller.shortsSuggestions.isNotEmpty) ...[
                      if (controller.contentSuggestions.isNotEmpty)
                        Divider(color: AppColors.white12, height: 1),
                      _buildSuggestionSectionHeader("SHORTS"),
                      for (int i = 0; i < controller.shortsSuggestions.length; i++) ...[
                        if (i > 0) Divider(color: AppColors.white10, height: 1),
                        _buildSuggestionTile(
                          controller,
                          controller.shortsSuggestions[i],
                          isShort: true,
                        ),
                      ],
                    ],

                    // Fallback if neither sublist is populated but suggestions has items
                    if (controller.contentSuggestions.isEmpty && controller.shortsSuggestions.isEmpty)
                      for (int i = 0; i < controller.suggestions.length; i++) ...[
                        if (i > 0) Divider(color: AppColors.white10, height: 1),
                        _buildSuggestionTile(
                          controller,
                          controller.suggestions[i],
                          isShort: controller.suggestions[i].item_type == 'shorts' ||
                              controller.suggestions[i].contentType == 'Short Series',
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSuggestionSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.black.withAlpha(80),
      child: AppTextWidget(
        text: title,
        color: AppColors.white54,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSuggestionTile(
    MySearchController controller,
    Items item, {
    required bool isShort,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Stack(
          children: [
            AppNetworkImage(
              imageUrl: item.thumbnail ?? item.poster ?? "",
              width: isShort ? 36.w : 40.w,
              height: 54.h,
              fit: BoxFit.cover,
            ),
            if (isShort)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha(40),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: AppColors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      title: AppTextWidget(
        text: item.title ?? "",
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Row(
          children: [
            if (isShort)
              Container(
                margin: EdgeInsets.only(right: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.appColors.withAlpha(220),
                  borderRadius: BorderRadius.circular(3.r),
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
            AppTextWidget(
              text: isShort
                  ? (item.contentType ?? "Short Series")
                  : (item.contentType ?? "Movie"),
              color: AppColors.white54,
              fontSize: 12,
            ),
          ],
        ),
      ),
      trailing: Icon(Icons.north_west, color: AppColors.white24, size: 16.sp),
      onTap: () {
        controller.showSuggestions.value = false;
        if (isShort || item.item_type == 'shorts' || item.contentType == 'Short Series') {
          Get.toNamed(
            RoutesName.reelShortsScreen,
            arguments: {
              'uuid': item.uuid ?? item.contentUuid,
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
    );
  }
}
