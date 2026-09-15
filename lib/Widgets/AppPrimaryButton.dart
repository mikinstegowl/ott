import 'package:flutter/material.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  final IconData? icon;
  final double? width;
  final bool isLoading;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appColors,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: isLoading
              ? [
                  SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  ),
                ]
              : [
                  AppTextWidget(
                    text: text,
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  if (icon != null) ...[
                    SizedBox(width: 8.w),
                    Icon(icon, color: AppColors.white, size: 18.sp),
                  ],
                ],
        ),
      ),
    );
  }
}
