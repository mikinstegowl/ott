import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';

class ContentDescription extends StatelessWidget {
  final String title;
  final String description;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ContentDescription({
    super.key,
    required this.title,
    required this.description,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: AppTextWidget(
            text: title.toUpperCase(),
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextWidget(
              text: description,
              fontSize: 14.sp,
              color: AppColors.lightWhite70,
              maxLines: isExpanded ? null : 3,
            ),
            if (description.length > 150)
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  margin: EdgeInsets.only(top: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.white   .withAlpha(25),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: AppTextWidget(
                    text: isExpanded ? "Read Less" : "Read More",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
