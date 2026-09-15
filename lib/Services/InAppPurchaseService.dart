import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ottapp/Constants/InAppPurchaseConstants.dart';

typedef OnPurchaseSuccess = Future<void> Function(PurchaseDetails purchase);
typedef OnPurchaseError = void Function(IAPError? error);
typedef OnPurchaseRestored = Future<void> Function(PurchaseDetails purchase);

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  OnPurchaseSuccess? onPurchaseSuccess;
  OnPurchaseError? onPurchaseError;
  OnPurchaseRestored? onPurchaseRestored;
  VoidCallback? onPurchasePending;

  /// Initialize In-App Purchase service and start listening to purchase stream
  Future<void> initialize({
    OnPurchaseSuccess? onPurchaseSuccess,
    OnPurchaseError? onPurchaseError,
    OnPurchaseRestored? onPurchaseRestored,
    VoidCallback? onPurchasePending,
  }) async {
    this.onPurchaseSuccess = onPurchaseSuccess;
    this.onPurchaseError = onPurchaseError;
    this.onPurchaseRestored = onPurchaseRestored;
    this.onPurchasePending = onPurchasePending;

    // Check if store is reachable on this device
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('[IAP] Store is not available on this device');
      return;
    }

    // Cancel existing subscription if re-initializing
    await _subscription?.cancel();

    // Listen to store purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('[IAP] Error on purchaseStream: $error');
        onPurchaseError?.call(null);
      },
    );

    // Preload products
    await loadProducts(InAppPurchaseConstants.allProductIds);
  }

  /// Query products configured in App Store Connect / Google Play Console
  Future<List<ProductDetails>> loadProducts(Set<String> productIds) async {
    if (!_isAvailable) {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) return [];
    }

    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('[IAP] Query error: ${response.error!.message}');
        return [];
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[IAP] Some product IDs not found in store: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      return _products;
    } catch (e) {
      debugPrint('[IAP] Exception while loading products: $e');
      return [];
    }
  }

  /// Initiate a purchase for a product
  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      debugPrint('[IAP] Cannot purchase: store unavailable');
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    final bool isConsumable = InAppPurchaseConstants.consumableProductIds.contains(product.id);

    try {
      if (isConsumable) {
        return await _iap.buyConsumable(purchaseParam: purchaseParam);
      } else {
        return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('[IAP] Exception while initiating purchase: $e');
      return false;
    }
  }

  /// Restore purchases (Mandatory for iOS App Store compliance)
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('[IAP] Exception while restoring purchases: $e');
    }
  }

  /// Handle incoming transactions from Apple StoreKit and Google Play Billing
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('[IAP] Transaction update: ${purchase.productID} -> ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          onPurchasePending?.call();
          break;

        case PurchaseStatus.error:
          onPurchaseError?.call(purchase.error);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          onPurchaseError?.call(purchase.error);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.purchased:
          if (onPurchaseSuccess != null) {
            await onPurchaseSuccess!(purchase);
          }
          // CRITICAL: Must complete/acknowledge transaction on Google Play & StoreKit
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.restored:
          if (onPurchaseRestored != null) {
            await onPurchaseRestored!(purchase);
          }
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
      }
    }
  }

  /// Dispose listeners
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
