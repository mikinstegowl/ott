import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Controllers/SplashController.dart';

/// The start-up slideshow.
///
/// Stays black until the first slide is ready, so the app never flashes a
/// half-drawn screen on a slow connection. Tapping anywhere skips ahead.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: GestureDetector(
        onTap: controller.skip,
        behavior: HitTestBehavior.opaque,
        child: Obx(() {
          if (controller.slides.isEmpty) {
            return const SizedBox.expand();
          }

          final slide = controller.slides[controller.index.value];

          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                child: CachedNetworkImage(
                  key: ValueKey(slide.id),
                  imageUrl: slide.image,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 250),
                  errorWidget: (_, __, ___) => const SizedBox.expand(),
                  placeholder: (_, __) => const SizedBox.expand(),
                ),
              ),

              // Wording needs a dark base or it disappears into bright artwork.
              if (slide.hasText)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                ),

              if (slide.hasText)
                Positioned(
                  left: 28.w,
                  right: 28.w,
                  bottom: 96.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (slide.headline?.isNotEmpty ?? false)
                        Text(
                          slide.headline!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      if (slide.subheadline?.isNotEmpty ?? false)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            slide.subheadline!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 15.sp,
                              height: 1.4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Progress pips, only when there is more than one slide.
              if (controller.slides.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 44.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(controller.slides.length, (i) {
                      final current = i == controller.index.value;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        width: current ? 18.w : 6.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: current
                              ? AppColors.appColors
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
