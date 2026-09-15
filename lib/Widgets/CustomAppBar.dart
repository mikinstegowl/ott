import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CustomAppBar({
    super.key,
    this.scaffoldKey,
  });

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. App Logo
          Image.asset(
            'assets/image/logo.png',
            height: 100.h,
            errorBuilder: (c, e, s) => AppTextWidget(
              text: "TREBOL",
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.appColors,
            ),
          ),
        ],
      ),
      actions: [
        // 2. Drawer Menu Icon (Only if scaffoldKey is provided)
        if (scaffoldKey != null)
          IconButton(
            onPressed: () => scaffoldKey!.currentState?.openDrawer(),
            icon: Icon(Icons.menu, size: 24.sp, color: AppColors.white),
          ),
        
        SizedBox(width: 8.w),
      ],
    );
  }
}
