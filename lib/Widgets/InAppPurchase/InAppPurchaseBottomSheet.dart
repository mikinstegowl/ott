import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Constants/InAppPurchaseConstants.dart';
import 'package:ottapp/Controllers/InAppPurchaseController.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ottapp/Localization/AppTranslations.dart';

class InAppPurchaseBottomSheet extends StatelessWidget {
  const InAppPurchaseBottomSheet({super.key, this.offerProductIds, this.title});

  /// Pay-per-view product ids for ONE title. Null means this is the
  /// subscription sheet, which must only ever list subscription plans —
  /// listing rentals and event tickets there offers something the viewer
  /// cannot act on from this screen.
  final List<String>? offerProductIds;

  /// Heading override, e.g. the film's name on a rent/buy sheet.
  final String? title;

  /// The live sheet's context, so the purchase controller can dismiss it
  /// once the server confirms. GetX cannot: this is a plain
  /// showModalBottomSheet, which `Get.isBottomSheetOpen` never sees.
  static BuildContext? _sheetContext;

  static void show(
    BuildContext context, {
    List<String>? offerProductIds,
    String? title,
    String? preselect,
  }) {
    // Someone who tapped Rent must not find Buy selected when the sheet opens:
    // the next tap is Continue, and buying costs several times what renting
    // does.
    if (preselect != null && preselect.isNotEmpty) {
      Get.put(InAppPurchaseController()).selectedProductId.value = preselect;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        _sheetContext = sheetContext;
        return InAppPurchaseBottomSheet(
          offerProductIds: offerProductIds,
          title: title,
        );
      },
    ).whenComplete(() => _sheetContext = null);
  }

  /// Dismiss the paywall. Called after a purchase is verified, so the sheet
  /// does not sit over a title the viewer has just paid for.
  static void close() {
    final ctx = _sheetContext;
    _sheetContext = null;

    if (ctx != null && ctx.mounted && Navigator.of(ctx).canPop()) {
      Navigator.of(ctx).pop();
    }
  }

  /// The heading, which has to match what is being sold. "Upgrade to VIP —
  /// unlimited episodes" is wrong above a 48-hour rental of one film.
  String get _heading => offerProductIds == null
      ? AppTranslations.resolve('paywall.choose_plan')
      : (title == null || title!.isEmpty ? AppTranslations.resolve('paywall.rent_or_buy') : 'Rent or buy $title');

  String get _subheading => offerProductIds == null
      ? AppTranslations.resolve('paywall.full_catalogue')
      : AppTranslations.resolve('paywall.one_payment');

  /// What this sheet is allowed to show.
  List<ProductDetails> _visibleProducts(InAppPurchaseController c) =>
      offerProductIds == null
          ? c.subscriptionProducts
          : c.ppvProductsFor(offerProductIds!);

  /// The product Continue will buy.
  ///
  /// The controller's selection is global, so it can be left pointing at a
  /// product this sheet does not show — a plan while a rent sheet is open,
  /// or the reverse. Resolving against the visible list keeps the highlight
  /// and the button agreeing with each other, and means the first row is
  /// always buyable without the viewer having to tap it first.
  ProductDetails? _selected(InAppPurchaseController c) {
    final visible = _visibleProducts(c);
    if (visible.isEmpty) return null;

    return visible.firstWhereOrNull((p) => p.id == c.selectedProductId.value) ??
        visible.first;
  }

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
                          text: _heading,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        SizedBox(height: 4.h),
                        AppTextWidget(
                          text: _subheading,
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
                        text: AppTranslations.resolve('paywall.no_products'),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      SizedBox(height: 4.h),
                      AppTextWidget(
                        text: AppTranslations.resolve('paywall.check_store'),
                        fontSize: 12.sp,
                        color: Colors.white54,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      TextButton.icon(
                        onPressed: controller.refreshProducts,
                        icon: const Icon(Icons.refresh, color: AppColors.appColors),
                        label: Text(
                          AppTranslations.resolve('common.retry'),
                          style: const TextStyle(color: AppColors.appColors),
                        ),
                      )
                    ],
                  ),
                )
              else
                ..._visibleProducts(controller).map((product) {
                  final isSelected = _selected(controller)?.id == product.id;
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
                        final selected = _selected(controller);
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
                        AppTranslations.resolve('common.continue'),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
              ),

              SizedBox(height: 12.h),

              // Restore Purchases (Mandatory for iOS App Store)
              Center(
                child: TextButton(
                  onPressed: controller.isPurchasing.value ? null : controller.restore,
                  child: Text(
                    AppTranslations.resolve('paywall.restore'),
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
                  _buildLegalLink(AppTranslations.resolve('paywall.terms'), InAppPurchaseConstants.termsOfServiceUrl),
                  Text(' • ', style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
                  _buildLegalLink(AppTranslations.resolve('paywall.privacy'), InAppPurchaseConstants.privacyPolicyUrl),
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
