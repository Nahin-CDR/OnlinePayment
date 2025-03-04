import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SinglePurchaseProvider with ChangeNotifier {
  final InAppPurchase iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool available = false;
  List<ProductDetails> products = [];
  List<PurchaseDetails> purchases = [];
  final String productId = 'com.example.testproduct2';

  Future<void> initialize() async {
    final purchaseUpdated = iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchases) {
      listenToPurchaseUpdated(purchases);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint('Error in purchase stream: $error');
    });

    // Check if in-app purchase is available
    available = await iap.isAvailable();
    if (!available) {
      notifyListeners();
      return;
    }

    // Query product details
    await loadProducts();
  }

  Future<void> loadProducts() async {
    // Query product details using the product id
    Set<String> ids = {productId};
    ProductDetailsResponse response = await iap.queryProductDetails(ids);
    if (response.error != null) {
      debugPrint('Error fetching products: ${response.error}');
    }
    if (response.productDetails.isEmpty) {
      debugPrint('No products found');
    }
    products = response.productDetails;
    notifyListeners();
  }

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Verify purchase and deliver product here
        debugPrint('Purchase successful: ${purchase.productID}');
        String receipt = purchase.verificationData.serverVerificationData;
        debugPrint('RECEIPT for purchase : $receipt');
        // এখানে subscription verification & delivery logic add করা যাবে
      }
      if (purchase.pendingCompletePurchase) {
        iap.completePurchase(purchase);
      }
    }
    purchases = purchaseDetailsList;
    notifyListeners();
  }

  void buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
    PurchaseParam(productDetails: productDetails);
    // Use buyConsumable for consumable purchases
    iap.buyConsumable(purchaseParam: purchaseParam);
  }
}
