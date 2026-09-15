import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Controllers/ViewAllController.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Constants/AppLoader.dart';
import 'package:ottapp/Widgets/VerticalRailWidget.dart';
import 'package:ottapp/Models/HomeModel.dart';

class ViewAllScreen extends GetView<ViewAllController> {
  const ViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        centerTitle: true,
        title: AppTextWidget(
          text: controller.title,
          color: AppColors.white,
          fontSize: 16,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppColors.black,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Grid of Items
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.items.isEmpty) {
                  return const Center(child: AppLoader());
                }

                if (controller.items.isEmpty) {
                  return Center(
                    child: AppTextWidget(
                      text: "No items found",
                      color: AppColors.white,
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      controller.loadMoreItems();
                    }
                    return false;
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 10.h,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 15.w,
                      mainAxisSpacing: 15.h,
                    ),
                    itemCount:
                        controller.items.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < controller.items.length) {
                        final item = controller.items[index];
                        return VerticalRailItem(
                          item: item,
                          section: Sections(
                            slug: controller.sectionSlug,
                            title: controller.title,
                            layoutType: controller.sectionData.value?.layoutType
                          ),
                          index: index,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      } else {
                        return Center(child: AppLoader());
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
