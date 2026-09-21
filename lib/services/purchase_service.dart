import 'dart:async';

import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles the "Remove Ads" subscription: querying the Monthly/Yearly
/// products from the store, buying/restoring them, and persisting the
/// resulting entitlement so ads stay off across restarts.
class PurchaseService extends ChangeNotifier {
  static const monthlyId = 'monthly';
  static const yearlyId = 'yearly';
  static const _productIds = <String>{monthlyId, yearlyId};
  static const _prefsKey = 'is_premium';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPremium = false;
  bool _isAvailable = false;
  bool _isLoadingProducts = false;
  String? _pendingProductId;
  String? _errorMessage;
  List<ProductDetails> _products = [];

  bool get isPremium => _isPremium;
  bool get isAvailable => _isAvailable;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isPurchasePending => _pendingProductId != null;
  String? get errorMessage => _errorMessage;
  List<ProductDetails> get products => List.unmodifiable(_products);

  ProductDetails? get monthly => _productOrNull(monthlyId);
  ProductDetails? get yearly => _productOrNull(yearlyId);

  ProductDetails? _productOrNull(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  /// Restores a previously-granted entitlement from disk and re-applies ad
  /// suppression. Call once at startup, before `runApp`.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_prefsKey) ?? false;
    if (_isPremium) AdManager.suppressAdsForever();
  }

  /// Connects to the store, starts listening for purchase updates, and
  /// loads the Monthly/Yearly product details. Safe to call without
  /// awaiting - the UI reacts to the resulting state changes.
  Future<void> initialize() async {
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      notifyListeners();
      return;
    }

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_isPremium) return;

    _isLoadingProducts = true;
    notifyListeners();

    final response = await _iap.queryProductDetails(_productIds);
    _products = response.productDetails;
    _isLoadingProducts = false;
    notifyListeners();
  }

  Future<void> buy(ProductDetails product) async {
    if (_isPremium || isPurchasePending) return;

    _errorMessage = null;
    _pendingProductId = product.id;
    notifyListeners();

    final started = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    if (!started) {
      _pendingProductId = null;
      _errorMessage = 'Could not start the purchase. Please try again.';
      notifyListeners();
    }
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (!_productIds.contains(purchase.productID)) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantPremium();
          break;
        case PurchaseStatus.error:
          _pendingProductId = null;
          _errorMessage = purchase.error?.message ?? 'Purchase failed.';
          break;
        case PurchaseStatus.canceled:
          _pendingProductId = null;
          break;
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    notifyListeners();
  }

  Future<void> _grantPremium() async {
    _isPremium = true;
    _pendingProductId = null;
    _errorMessage = null;
    AdManager.suppressAdsForever();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
