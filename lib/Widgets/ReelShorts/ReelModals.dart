import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:ottapp/Widgets/ContentDetails/ShareDialogWidget.dart';

/// Helper class containing popup dialogs & bottom sheets for ReelShorts
class ReelModals {
  /// Daily Check-in Claim Reward Dialog
  static void showClaimRewardDialog(
    BuildContext context, {
    required VoidCallback onClaim,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: Colors.amber, width: 1),
          ),
          title: Row(
            children: [
              Icon(Icons.military_tech_rounded,
                  color: Colors.amber, size: 26.sp),
              SizedBox(width: 8.w),
              AppTextWidget(
                text: "Daily Check-in Reward",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monetization_on_rounded,
                color: Colors.amber,
                size: 55.sp,
              ),
              SizedBox(height: 10.h),
              AppTextWidget(
                text: "+20 Coins Added!",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amberAccent,
              ),
              SizedBox(height: 6.h),
              AppTextWidget(
                text:
                    "Keep watching episodes to unlock daily treasure chests and rewards.",
                fontSize: 12,
                color: Colors.white70,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onClaim();
              },
              child: AppTextWidget(
                text: "Claim Now",
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF2A55),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Full Drama Details & Cast Modal (from end of video)
  static void showDramaDetailsModal(
    BuildContext context, {
    required String dramaTitle,
    required String synopsis,
    required List<String> tags,
    required List<Map<String, String>> cast,
    required int currentEpisode,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (detailsContext) {
        return Container(
          height: 0.65.sh,
          decoration: BoxDecoration(
            color: const Color(0xFF16161B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              Row(
                children: [
                  Expanded(
                    child: AppTextWidget(
                      text: dramaTitle,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(detailsContext).pop(),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Tags
              Wrap(
                spacing: 8.w,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    labelStyle: TextStyle(fontSize: 11.sp, color: Colors.white),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                  );
                }).toList(),
              ),

              SizedBox(height: 12.h),

              AppTextWidget(
                text: "Synopsis",
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              SizedBox(height: 6.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 120.h),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: AppTextWidget(
                    text: synopsis,
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Cast List
              AppTextWidget(
                text: "Cast & Crew",
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 85.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cast.length,
                  separatorBuilder: (_, __) => SizedBox(width: 14.w),
                  itemBuilder: (context, index) {
                    final actor = cast[index];
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: Colors.white12,
                          child: Icon(Icons.person,
                              color: Colors.white70, size: 24.sp),
                        ),
                        SizedBox(height: 4.h),
                        AppTextWidget(
                          text: actor["name"] ?? "",
                          fontSize: 11,
                          color: Colors.white,
                          maxLines: 1,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),

              ElevatedButton.icon(
                onPressed: () => Navigator.of(detailsContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A55),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: AppTextWidget(
                  text: "Continue Watching EP. $currentEpisode",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
    );
  }

  /// Social Sharing Sheet
  static void showShareModal(BuildContext context, {Share? shareData}) {
    if (shareData != null && shareData.url != null) {
      Get.bottomSheet(
        ShareDialogWidget(shareData: shareData),
        isScrollControlled: true,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E26),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  AppTextWidget(
                    text: "Share with Friends",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildShareIcon(Icons.link_rounded, "Copy Link", () {
                        Navigator.pop(context);
                        Get.snackbar("Copied", "Link copied to clipboard",
                            snackPosition: SnackPosition.BOTTOM);
                      }),
                      _buildShareIcon(Icons.message_rounded, "Message", () {
                        Navigator.pop(context);
                      }),
                      _buildShareIcon(Icons.send_rounded, "WhatsApp", () {
                        Navigator.pop(context);
                      }),
                      _buildShareIcon(Icons.more_horiz_rounded, "More", () {
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildShareIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: Colors.white12,
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          AppTextWidget(
            text: label,
            fontSize: 11,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}
