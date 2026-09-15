import 'package:flutter/material.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';

import '../Models/GetAllGenreModel.dart' as getAllGenreModel;

class GenreRailWidget extends StatelessWidget {
  final Sections section;
  final List<getAllGenreModel.Data> data;
  final VoidCallback? onLoadMore;
  const GenreRailWidget({
    super.key,
    required this.section,
    required this.data,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final items = section.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppTextWidget(
                  text: section.title ?? "Genres",
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                ),
              ),
              // if (section.hasMore == true)
              //   Padding(
              //     padding: EdgeInsets.only(left: 8.w),
              //     child: AppTextWidget(
              //       text: "See All",
              //       color: Colors.red,
              //       fontSize: 14,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            padding: EdgeInsets.only(left: 15.w),
            itemBuilder: (context, index) {
              // final item = items[index];
              // if (index == items.length - 4 && section.hasMore == true) {
              //   WidgetsBinding.instance.addPostFrameCallback((_) {
              //     onLoadMore?.call();
              //   });
              // }
              return GestureDetector(
                // onTap: () => Get.toNamed(RoutesName.infoScreen, arguments: data.contentUuid ?? item.uuid),
                child: Container(
                  width: 180.w,
                  margin: EdgeInsets.only(right: 15.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(
                          imageUrl: data[index].thumbnail ?? "",
                          fit: BoxFit.cover,
                        ),
                        Container(color: AppColors.blackOpacity50),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: AppTextWidget(
                              text: data[index].name ?? "",
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
