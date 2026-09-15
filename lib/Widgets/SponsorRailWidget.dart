import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SponsorRailWidget extends StatelessWidget {
  final Sections section;
  const SponsorRailWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final items = section.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null && section.title!.isNotEmpty) ...[
          SizedBox(height: 25.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: AppTextWidget(
              text: section.title!,
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        SizedBox(height: 15.h),
        CarouselSlider.builder(
          itemCount: items.length,
          options: CarouselOptions(
            height: 70.h,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: false,
          ),
          itemBuilder: (context, index, realIndex) {
            final item = items[index];
            final imageUrl = item.image  ?? "";
            
            return GestureDetector(
              onTap: () async {
                if (item.url != null && item.url!.isNotEmpty) {
                  final uri = Uri.parse(item.url!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black54,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
