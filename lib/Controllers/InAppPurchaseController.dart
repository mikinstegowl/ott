import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Network/AppChopperClient.dart';
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

  /// Store product ids as the SERVER defines them, so a new plan or a renamed
  /// product needs no app release and no store review.
  final RxList<Map<String, dynamic>> serverPlans = <Map<String, dynamic>>[].obs;
  Set<String> _serverProductIds = <String>{};

  /// Subscription product ids, as the server defines them.
  final RxSet<String> planProductIds = <String>{}.obs;

  /// Pay-per-view product ids (rent / buy tickets).
  final RxSet<String> ppvProductIds = <String>{}.obs;

  /// Only the subscription plans — what the "upgrade" sheet must show.
  /// Showing every product here listed rentals and event tickets alongside
  /// the monthly plans, which is not an offer anyone can act on.
  List<ProductDetails> get subscriptionProducts => products
      .where((p) => planProductIds.isEmpty || planProductIds.contains(p.id))
      .toList();

  /// Only the tickets for one title, in the order the server listed them.
  List<ProductDetails> ppvProductsFor(Iterable<String> ids) {
    final wanted = ids.toSet();

    return products.where((p) => wanted.contains(p.id)).toList();
  }

  /// Ask the backend which store products to offer. Falls back to the ids
  /// bundled in the app if the call fails, so the paywall still works offline.
  Future<Set<String>> _loadProductIdsFromServer() async {
    try {
      final service = AppChopperClient().getChopperService<HomeChopperService>();
      final response = await service.appProducts(Platform.isIOS ? 'apple' : 'google');
      final body = response.body;

      if (!response.isSuccessful || body is! Map || body['success'] != true) {
        return InAppPurchaseConstants.allProductIds;
      }

      final data = body['data'] as Map;
      final ids = <String>{};

      final plans = (data['plans'] as List?) ?? const [];
      serverPlans.assignAll(plans.map((e) => Map<String, dynamic>.from(e as Map)));
      planProductIds.clear();
      for (final p in serverPlans) {
        final id = p['product_id'];
        if (id is String && id.isNotEmpty) {
          ids.add(id);
          planProductIds.add(id);
        }
      }

      ppvProductIds.clear();
      for (final t in ((data['ppv'] as List?) ?? const [])) {
        for (final key in ['rent_product_id', 'buy_product_id']) {
          final id = (t as Map)[key];
          if (id is String && id.isNotEmpty) {
            ids.add(id);
            ppvProductIds.add(id);
          }
        }
      }

      if (ids.isEmpty) return InAppPurchaseConstants.allProductIds;

      _serverProductIds = ids;
      debugPrint('[IapController] ${ids.length} product id(s) from the server');

      return ids;
    } catch (e) {
      debugPrint('[IapController] Could not load product ids from the server: $e');
      return InAppPurchaseConstants.allProductIds;
    }
  }

  Future<void> _initIap() async {
    isLoadingProducts.value = true;
    try {
      final productIds = await _loadProductIdsFromServer();

      await _iapService.initialize(
        productIds: productIds,
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
        isMockMode.value = kDebugMode;
        if (kDebugMode) products.assignAll(_getMockProducts());
      }

      if (products.isNotEmpty) {
        selectedProductId.value = products.first.id;
      }
    } catch (e) {
      debugPrint('[IapController] Error initializing: $e');
      if (products.isEmpty) {
        isMockMode.value = kDebugMode;
        if (kDebugMode) products.assignAll(_getMockProducts());
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
      final items = await _iapService.loadProducts(
        _serverProductIds.isNotEmpty ? _serverProductIds : await _loadProductIdsFromServer(),
      );
      if (items.isNotEmpty) {
        isMockMode.value = false;
        products.assignAll(items);
      } else {
        isMockMode.value = kDebugMode;
        if (kDebugMode) products.assignAll(_getMockProducts());
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

    // Mock Mode exists so the screens can be built before the store products
    // are live. It grants access WITHOUT a payment, so it is debug-only — in a
    // release build it can never run, whatever the store returns.
    if (isMockMode.value && kDebugMode) {
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
        lastVerificationError.value.isNotEmpty
            ? lastVerificationError.value
            : 'Could not verify purchase with server. Please contact support.',
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

    // A restored receipt is verified exactly like a new one.
    final bool verified = await _verifyReceiptWithServer(purchase);

    if (!verified) {
      Utility.showSnackBar(
        lastVerificationError.value.isNotEmpty
            ? lastVerificationError.value
            : 'That purchase could not be restored.',
        isError: true,
      );
      return;
    }

    _deliverContent(purchase);
    Utility.showSnackBar('Your purchase has been successfully restored!');
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  /// Refresh from the server after a verified purchase.
  ///
  /// It deliberately does NOT set `isSubscribed` here: the server has just
  /// granted the subscription, so the profile call is the source of truth.
  /// Setting it locally used to unlock content even when verification failed.
  void _deliverContent(PurchaseDetails purchase) {
    fetchUserProfile();
  }

  /// Grant privileges in Mock Mode (debug builds only — see purchase()).
  void _deliverMockContent(ProductDetails product) {
    if (InAppPurchaseConstants.subscriptionProductIds.contains(product.id) ||
        product.id == InAppPurchaseConstants.lifetimeVipId) {
      BaseController.isSubscribed.value = true;
    }
    fetchUserProfile();
  }

  /// Hand the store's receipt to our server, which checks it with Apple or
  /// Google and grants the subscription or ticket on the account.
  ///
  /// This is the only thing that unlocks content. The app deliberately does
  /// not decide for itself: a receipt can be faked on a jailbroken device, and
  /// access bought on a phone has to appear on the website and TV too, which
  /// only the server can do.
  Future<bool> _verifyReceiptWithServer(PurchaseDetails purchase) async {
    try {
      final service = AppChopperClient().getChopperService<HomeChopperService>();

      final response = await service.verifyAppPurchase({
        'platform': Platform.isIOS ? 'apple' : 'google',
        'product_id': purchase.productID,
        'token': purchase.verificationData.serverVerificationData,
        // Set by the caller when a pay-per-view ticket is for one title.
        if (pendingContentUuid != null) 'content_uuid': pendingContentUuid,
        if (pendingLiveUuid != null) 'live_uuid': pendingLiveUuid,
      });

      final body = response.body;
      final ok = response.isSuccessful && (body is Map && body['success'] == true);

      if (!ok) {
        final message = (body is Map ? body['message'] : null) ??
            'We could not confirm that purchase.';
        debugPrint('[IapController] Server rejected the receipt: $message');
        lastVerificationError.value = message.toString();
      }

      return ok;
    } catch (e) {
      // A network failure here is recoverable: the store keeps the purchase,
      // and "Restore purchases" or the next app start replays it.
      debugPrint('[IapController] Verification call failed: $e');
      lastVerificationError.value =
          'We could not reach the server. Your purchase is safe — open the app again, or use Restore Purchases.';
      return false;
    }
  }

  /// Which title a pay-per-view purchase is for, set before buying.
  String? pendingContentUuid;
  String? pendingLiveUuid;

  /// Why the last verification failed, for the UI to show.
  final RxString lastVerificationError = ''.obs;

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
