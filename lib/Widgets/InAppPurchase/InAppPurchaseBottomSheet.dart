import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Constants/InAppPurchaseConstants.dart';
import 'package:ottapp/Controllers/InAppPurchaseController.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppPurchaseBottomSheet extends StatelessWidget {
  const InAppPurchaseBottomSheet({super.key, this.offerProductIds, this.title});

  /// Pay-per-view product ids for ONE title. Null means this is the
  /// subscription sheet, which must only ever list subscription plans —
  /// listing rentals and event tickets there offers something the viewer
  /// cannot act on from this screen.
  final List<String>? offerProductIds;

  /// Heading override, e.g. the film's name on a rent/buy sheet.
  final String? title;

  static void show(
    BuildContext context, {
    List<String>? offerProductIds,
    String? title,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InAppPurchaseBottomSheet(
        offerProductIds: offerProductIds,
        title: title,
      ),
    );
  }

  /// What this sheet is allowed to show.
  List<ProductDetails> _visibleProducts(InAppPurchaseController c) =>
      offerProductIds == null
          ? c.subscriptionProducts
          : c.ppvProductsFor(offerProductIds!);

  @override
  Widget build(BuildContext context) {
    final InAppPurchaseController controller = Get.put(InAppPurchaseController());

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextWidget(
                          text: 'Upgrade to VIP',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        SizedBox(height: 4.h),
                        AppTextWidget(
                          text: 'Unlock unlimited episodes & ad-free streaming',
                          fontSize: 13.sp,
                          color: AppColors.lightWhite70,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Product List / State Handling
              if (controller.isLoadingProducts.value)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.appColors),
                  ),
                )
              else if (_visibleProducts(controller).isEmpty)
                Container(
                  padding: EdgeInsets.all(16.r),
                  margin: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.storefront_outlined, size: 40.sp, color: Colors.white54),
                      SizedBox(height: 8.h),
                      AppTextWidget(
                        text: 'No products found',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      SizedBox(height: 4.h),
                      AppTextWidget(
                        text: 'Please check your Store setup or try again later.',
                        fontSize: 12.sp,
                        color: Colors.white54,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      TextButton.icon(
                        onPressed: controller.refreshProducts,
                        icon: const Icon(Icons.refresh, color: AppColors.appColors),
                        label: const Text(
                          'Retry',
                          style: TextStyle(color: AppColors.appColors),
                        ),
                      )
                    ],
                  ),
                )
              else
                ..._visibleProducts(controller).map((product) {
                  final isSelected = controller.selectedProductId.value == product.id;
                  return _buildProductCard(product, isSelected, () {
                    controller.selectedProductId.value = product.id;
                  });
                }),

              SizedBox(height: 16.h),

              // Purchase Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appColors,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: controller.isPurchasing.value ||
                        _visibleProducts(controller).isEmpty
                    ? null
                    : () {
                        final selected = _visibleProducts(controller).firstWhereOrNull(
                          (p) => p.id == controller.selectedProductId.value,
                        );
                        if (selected != null) {
                          controller.purchase(selected);
                        }
                      },
                child: controller.isPurchasing.value
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Continue',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
              ),

              SizedBox(height: 12.h),

              // Restore Purchases (Mandatory for iOS App Store)
              Center(
                child: TextButton(
                  onPressed: controller.isPurchasing.value ? null : controller.restore,
                  child: Text(
                    'Restore Purchases',
                    style: TextStyle(
                      color: AppColors.lightWhite70,
                      fontSize: 13.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              // Terms of Service & Privacy Policy (Mandatory for iOS App Store Subscriptions)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegalLink('Terms of Use', InAppPurchaseConstants.termsOfServiceUrl),
                  Text(' • ', style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
                  _buildLegalLink('Privacy Policy', InAppPurchaseConstants.privacyPolicyUrl),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProductCard(ProductDetails product, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appColors.withValues(alpha: 0.15) : Colors.white10,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.appColors : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product.description.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12.sp,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              product.price,
              style: TextStyle(
                color: isSelected ? AppColors.appColors : Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLink(String title, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}
