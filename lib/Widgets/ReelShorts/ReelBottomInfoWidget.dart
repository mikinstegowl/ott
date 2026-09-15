import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';

/// Bottom left information with drama title, tags, and expandable synopsis
class ReelBottomInfoWidget extends StatelessWidget {
  final String dramaTitle;
  final String synopsis;
  final List<String> tags;
  final bool isSynopsisExpanded;
  final VoidCallback onTapTitle;
  final VoidCallback onToggleSynopsis;

  const ReelBottomInfoWidget({
    super.key,
    required this.dramaTitle,
    required this.synopsis,
    required this.tags,
    required this.isSynopsisExpanded,
    required this.onTapTitle,
    required this.onToggleSynopsis,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 14.w, right: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drama Title with clickable arrow (opens synopsis modal)
          GestureDetector(
            onTap: onTapTitle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AppTextWidget(
                    text: dramaTitle,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Actor & Category Chips
          Wrap(
            spacing: 6.w,
            children: tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: AppTextWidget(
                  text: tag,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 8.h),

          // Expandable Synopsis (Shows full text when expanded)
          if (synopsis.isNotEmpty)
            GestureDetector(
              onTap: onToggleSynopsis,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSynopsisExpanded)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 220.h),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          synopsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: Colors.white,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      synopsis,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: Colors.white,
                        height: 1.4,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),

                  // "More" / "Less" toggle indicator in brand green
                  if (synopsis.length > 70) ...[
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppTextWidget(
                          text: isSynopsisExpanded ? "Less" : "More",
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appColors,
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          isSynopsisExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.appColors,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

