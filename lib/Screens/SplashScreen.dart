import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Controllers/SplashController.dart';

/// The first screen: what is on now, and who is watching.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          Expanded(child: _Promo(controller: controller)),
          _ProfilePicker(controller: controller),
        ],
      ),
    );
  }
}

/// The rotating artwork. Fades into the page so the profile below feels part
/// of the same screen rather than a panel stuck underneath.
class _Promo extends StatelessWidget {
  const _Promo({required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.slides.isEmpty) {
        return const SizedBox.expand();
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onSlideChanged,
            itemCount: controller.slides.length,
            itemBuilder: (_, i) {
              final slide = controller.slides[i];
              return CachedNetworkImage(
                imageUrl: slide.image,
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                errorWidget: (_, __, ___) => const SizedBox.expand(),
                placeholder: (_, __) => const SizedBox.expand(),
              );
            },
          ),

          // Reads over any artwork, bright or dark.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.black],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 26.h,
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final slide = controller.slides.isEmpty
                        ? null
                        : controller.slides[controller.index.value];

                    if (slide == null || !slide.hasText) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (slide.headline?.isNotEmpty ?? false)
                          Text(
                            slide.headline!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        if (slide.subheadline?.isNotEmpty ?? false)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Text(
                              slide.subheadline!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14.sp,
                                height: 1.4,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),

                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// One profile, because one account is one person here.
class _ProfilePicker extends StatelessWidget {
  const _ProfilePicker({required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The heading sits on the artwork's black, above the sheet, so the
        // curve reads as the sheet rising rather than as a stray divider.
        Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Text(
            'Choose your profile',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B30),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(160.r),
              topRight: Radius.circular(160.r),
            ),
          ),
          padding: EdgeInsets.only(top: 22.h, bottom: 38.h),
          child: Obx(
            () => _ProfileTile(
              name: controller.profileName,
              initial: controller.profileInitial,
              avatar: controller.profileAvatar,
              onTap: controller.enter,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.name,
    required this.initial,
    required this.avatar,
    required this.onTap,
  });

  final String name;
  final String initial;
  final String? avatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final side = 88.w;

    return Semantics(
      button: true,
      label: 'Continue as $name',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: side,
                height: side,
                decoration: BoxDecoration(
                  color: AppColors.appColors,
                  borderRadius: BorderRadius.circular(14.r),
                  image: (avatar != null && avatar!.isNotEmpty)
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: (avatar == null || avatar!.isEmpty)
                    ? Text(
                        initial,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: side + 24.w,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
