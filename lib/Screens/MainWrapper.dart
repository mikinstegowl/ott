import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/Controllers/MainWrapperController.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';

class MainWrapper extends GetView<MainWrapperController> {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final bool shouldPop = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      side: const BorderSide(color: AppColors.white10),
                    ),
                    title: AppTextWidget(
                      text: "Exit App",
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    content: AppTextWidget(
                      text: "Are you sure you want exit this app",
                      color: AppColors.lightWhite70,
                      fontSize: 14,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: AppTextWidget(
                          text: "No",
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: AppTextWidget(
                          text: "Yes",
                          color: AppColors.appColors,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
            ) ??
            false;

        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: controller.screens,
          ),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            backgroundColor: AppColors.black,
            selectedItemColor: AppColors.appColors,
            unselectedItemColor: AppColors.grey,
            iconSize: 22.sp,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              controller.changePage(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.movie),
                label: AppText.bottombar_home,
              ),
              if (controller.isLiveVideoActive.value)
                BottomNavigationBarItem(
                  icon: const Icon(Icons.video_library),
                  label: AppText.bottombar_vdeos,
                ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search),
                label: AppText.bottomBar_search,
              ),
              if (!controller.isGuest)
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: AppText.bottomBar_profile,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
