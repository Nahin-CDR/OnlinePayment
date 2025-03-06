import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionProvider extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool isAvailable = false;
  bool isLoading = true;
  List<ProductDetails> products = [];

  SubscriptionProvider() {
    _initialize();
    _listenToPurchaseUpdates();
  }

  Future<void> _initialize() async {
    isAvailable = await _inAppPurchase.isAvailable();
    if (isAvailable) {
      await _loadProducts();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    const Set<String> ids = <String>{'test.coins200'}; // আপনার সাবস্ক্রিপশন ID
    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(ids);

    if (response.productDetails.isNotEmpty) {
      products = response.productDetails;
    }
    notifyListeners();
  }

  // purchase stream listener setup
  void _listenToPurchaseUpdates() {
    _subscription = _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // এখানে error handle করুন
      print("Purchase stream error: $error");
    });
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Payment successful - receipt details প্রিন্ট করা হলো
        print("Payment Successful!");
        print("Receipt: ${purchaseDetails.verificationData.serverVerificationData}");
        print("Receipt: ${purchaseDetails.verificationData.localVerificationData}");
        print("Receipt: ${purchaseDetails.verificationData.source}");
        // এখানে আপনি receipt verify বা acknowledge করতে পারেন, যদি প্রয়োজন হয়।
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print("Purchase error: ${purchaseDetails.error}");
      }
      // অন্যান্য স্ট্যাটাস যেমন pending, etc. handle করতে পারেন
    }
  }

  void purchaseSubscription(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
