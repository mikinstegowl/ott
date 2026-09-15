import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Constants/CustomSnackBar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ottapp/Constants/ShareHelper.dart';

class ShareDialogWidget extends StatelessWidget {
  final Share shareData;

  const ShareDialogWidget({super.key, required this.shareData});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Utility.showSnackBar("Could not open application", isError: true);
    }
  }

  void _shareToPlatform(String platform) {
    if (shareData.url == null) return;
    
    final url = Uri.encodeComponent(shareData.url!);
    final text = Uri.encodeComponent(shareData.title ?? '');
    
    switch (platform) {
      case 'facebook':
        _launchUrl('https://www.facebook.com/sharer/sharer.php?u=$url');
        break;
      case 'x':
        _launchUrl('https://twitter.com/intent/tweet?url=$url&text=$text');
        break;
      case 'whatsapp':
        ShareHelper.openWhatsApp(
          text: shareData.title ?? '',
          url: shareData.url ?? '',
        ).then((opened) {
          if (!opened) {
            ShareHelper.shareNative(shareData: shareData);
          }
        });
        break;
      case 'telegram':
        _launchUrl('https://t.me/share/url?url=$url&text=$text');
        break;
      case 'linkedin':
        _launchUrl('https://www.linkedin.com/sharing/share-offsite/?url=$url');
        break;
      case 'more':
        Get.back();
        ShareHelper.shareNative(shareData: shareData);
        break;
    }
  }

  void _copyLink() {
    if (shareData.url != null) {
      Clipboard.setData(ClipboardData(text: shareData.url!));
      Utility.showSnackBar("Link copied to clipboard");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppTextWidget(
                text: "Share",
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.white),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          
          // Share Content Card
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: AppNetworkImage(
                    imageUrl: shareData.image ?? '',
                    width: 60.w,
                    height: 40.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextWidget(
                        text: shareData.title ?? "",
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                      ),
                      SizedBox(height: 4.h),
                      AppTextWidget(
                        text: shareData.description ?? "",
                        color: AppColors.lightWhite70,
                        fontSize: 12,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25.h),
          
          // Social Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialIcon(FontAwesomeIcons.facebookF, "Facebook", 'facebook'),
              _buildSocialIcon(FontAwesomeIcons.xTwitter, "X (Twitter)", 'x'),
              _buildSocialIcon(FontAwesomeIcons.whatsapp, "WhatsApp", 'whatsapp'),
              _buildSocialIcon(FontAwesomeIcons.telegram, "Telegram", 'telegram'),
              _buildSocialIcon(FontAwesomeIcons.ellipsis, "More", 'more'),
            ],
          ),
          SizedBox(height: 25.h),
          
          // Copy Link
          AppTextWidget(
            text: "Copy Link",
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppTextWidget(
                    text: shareData.url ?? "",
                    color: AppColors.lightWhite70,
                    fontSize: 13,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: _copyLink,
                  child: Icon(Icons.copy_rounded, color: AppColors.white, size: 20.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildSocialIcon(IconData icon, String label, String platform) {
    return GestureDetector(
      onTap: () => _shareToPlatform(platform),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2C),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.white, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          AppTextWidget(
            text: label,
            color: AppColors.lightWhite70,
            fontSize: 10,
          ),
        ],
      ),
    );
  }
}
