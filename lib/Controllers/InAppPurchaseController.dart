import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ottapp/Constants/CustomSnackBar.dart';
import 'package:ottapp/Constants/InAppPurchaseConstants.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Services/InAppPurchaseService.dart';

class InAppPurchaseController extends BaseController {
  final InAppPurchaseService _iapService = InAppPurchaseService();

  final RxBool isStoreAvailable = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isPurchasing = false.obs;
  final RxBool isMockMode = false.obs;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxString selectedProductId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initIap();
  }

  Future<void> _initIap() async {
    isLoadingProducts.value = true;
    try {
      await _iapService.initialize(
        onPurchaseSuccess: _handlePurchaseSuccess,
        onPurchaseError: _handlePurchaseError,
        onPurchaseRestored: _handlePurchaseRestored,
        onPurchasePending: () {
          isPurchasing.value = true;
        },
      );

      isStoreAvailable.value = _iapService.isAvailable;

      if (_iapService.products.isNotEmpty) {
        isMockMode.value = false;
        products.assignAll(_iapService.products);
      } else {
        // Fallback for development / when store products are not yet published
        isMockMode.value = true;
        products.assignAll(_getMockProducts());
      }

      if (products.isNotEmpty) {
        selectedProductId.value = products.first.id;
      }
    } catch (e) {
      debugPrint('[IapController] Error initializing: $e');
      if (products.isEmpty) {
        isMockMode.value = true;
        products.assignAll(_getMockProducts());
        if (products.isNotEmpty) {
          selectedProductId.value = products.first.id;
        }
      }
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Reload products from store (or reload mock if store unavailable)
  Future<void> refreshProducts() async {
    isLoadingProducts.value = true;
    try {
      final items = await _iapService.loadProducts(InAppPurchaseConstants.allProductIds);
      if (items.isNotEmpty) {
        isMockMode.value = false;
        products.assignAll(items);
      } else {
        isMockMode.value = true;
        products.assignAll(_getMockProducts());
      }
      if (products.isNotEmpty && selectedProductId.value.isEmpty) {
        selectedProductId.value = products.first.id;
      }
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Trigger purchase flow for a product
  Future<void> purchase(ProductDetails product) async {
    isPurchasing.value = true;

    // In Mock Mode (e.g. testing without Google Play Console access):
    if (isMockMode.value) {
      await Future.delayed(const Duration(milliseconds: 1000));
      isPurchasing.value = false;
      _deliverMockContent(product);
      Utility.showSnackBar(
        'Success! Subscribed to ${product.title} (Test Mode)',
      );
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
      return;
    }

    // Real Store Purchase:
    final success = await _iapService.buyProduct(product);
    if (!success) {
      isPurchasing.value = false;
      Utility.showSnackBar(
        'Could not initiate purchase. Please try again.',
        isError: true,
      );
    }
  }

  /// Restore purchases (Mandatory for iOS App Review)
  Future<void> restore() async {
    isPurchasing.value = true;
    try {
      if (isMockMode.value) {
        await Future.delayed(const Duration(milliseconds: 800));
        BaseController.isSubscribed.value = true;
        Utility.showSnackBar('Your purchases have been restored! (Test Mode)');
        return;
      }

      await _iapService.restorePurchases();
      Utility.showSnackBar('Checking for previous purchases...');
    } catch (e) {
      Utility.showSnackBar(
        'Restore failed: $e',
        isError: true,
      );
    } finally {
      isPurchasing.value = false;
    }
  }

  /// Called when a real purchase transaction succeeds
  Future<void> _handlePurchaseSuccess(PurchaseDetails purchase) async {
    isPurchasing.value = false;
    debugPrint('[IapController] Purchase succeeded: ${purchase.productID}');

    final bool verified = await _verifyReceiptWithServer(purchase);

    if (verified) {
      _deliverContent(purchase);
      Utility.showSnackBar('Thank you! Your purchase was completed.');
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
    } else {
      Utility.showSnackBar(
        'Could not verify purchase with server. Please contact support.',
        isError: true,
      );
    }
  }

  /// Called when purchase has an error or is cancelled
  void _handlePurchaseError(IAPError? error) {
    isPurchasing.value = false;
    final message = error?.message ?? 'Purchase was cancelled or failed.';
    debugPrint('[IapController] Purchase error: $message');
    Utility.showSnackBar(
      message,
      isError: true,
    );
  }

  /// Called when a non-consumable or subscription is restored
  Future<void> _handlePurchaseRestored(PurchaseDetails purchase) async {
    isPurchasing.value = false;
    debugPrint('[IapController] Purchase restored: ${purchase.productID}');
    _deliverContent(purchase);
    Utility.showSnackBar('Your purchase has been successfully restored!');
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  /// Grant privileges locally or call user profile refresh
  void _deliverContent(PurchaseDetails purchase) {
    if (InAppPurchaseConstants.subscriptionProductIds.contains(purchase.productID) ||
        purchase.productID == InAppPurchaseConstants.lifetimeVipId) {
      BaseController.isSubscribed.value = true;
    }
    fetchUserProfile();
  }

  /// Grant privileges in Mock Mode
  void _deliverMockContent(ProductDetails product) {
    if (InAppPurchaseConstants.subscriptionProductIds.contains(product.id) ||
        product.id == InAppPurchaseConstants.lifetimeVipId) {
      BaseController.isSubscribed.value = true;
    }
    fetchUserProfile();
  }

  /// Server verification hook
  Future<bool> _verifyReceiptWithServer(PurchaseDetails purchase) async {
    return true;
  }

  /// Mock products displayed when Google Play / App Store products are not yet published
  List<ProductDetails> _getMockProducts() {
    return [
      ProductDetails(
        id: InAppPurchaseConstants.monthlySubscriptionId,
        title: 'Monthly VIP Pass',
        description: 'Unlimited streaming for 1 month',
        price: '\$4.99 / mo',
        rawPrice: 4.99,
        currencyCode: 'USD',
      ),
      ProductDetails(
        id: InAppPurchaseConstants.yearlySubscriptionId,
        title: 'Yearly VIP Pass (Save 40%)',
        description: 'Best Value! Full access for 12 months',
        price: '\$39.99 / yr',
        rawPrice: 39.99,
        currencyCode: 'USD',
      ),
      ProductDetails(
        id: InAppPurchaseConstants.lifetimeVipId,
        title: 'Lifetime VIP Access',
        description: 'Pay once, unlimited streaming forever',
        price: '\$99.99',
        rawPrice: 99.99,
        currencyCode: 'USD',
      ),
      ProductDetails(
        id: InAppPurchaseConstants.coins100Id,
        title: '100 Coins Pack',
        description: 'Unlock episodes and shorts instantly',
        price: '\$0.99',
        rawPrice: 0.99,
        currencyCode: 'USD',
      ),
    ];
  }

  @override
  void onClose() {
    _iapService.dispose();
    super.onClose();
  }
}
