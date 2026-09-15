import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Const/AppColors.dart';

class SectionSkeleton extends StatelessWidget {
  const SectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (index) => const SkeletonRail()),
    );
  }
}

class SkeletonRail extends StatelessWidget {
  const SkeletonRail({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Container(
            width: 150.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppColors.white10,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            padding: EdgeInsets.only(left: 15.w),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                width: 120.w,
                margin: EdgeInsets.only(right: 15.w),
                decoration: BoxDecoration(
                  color: AppColors.white10,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
