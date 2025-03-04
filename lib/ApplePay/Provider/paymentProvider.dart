
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentProvider with ChangeNotifier{
  final InAppPurchase iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> subscription;
  bool available = false;
  List<ProductDetails> products = [];


  final Set<String> productIds = {
    'com.example.starter',
    'com.example.gold',
    'com.example.platinum',
  };

  Future<void> initialize() async {
    available = await iap.isAvailable();
    if (!available) {
      notifyListeners();
      return;
    }
    // Query the product details for the given product IDs
    ProductDetailsResponse response = await iap.queryProductDetails(productIds);
    if (response.error != null) {
      debugPrint('Error fetching products: ${response.error}');
    }
    if (response.productDetails.isNotEmpty) {
      products = response.productDetails;
      notifyListeners();
    }




    final purchaseUpdated = iap.purchaseStream;
    subscription = purchaseUpdated.listen((purchases) {
      listenToPurchaseUpdated(purchases);
    }, onDone: () {
      subscription.cancel();
    }, onError: (error) {
      debugPrint('Purchase update error: $error');
    });



  }
  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        debugPrint('Purchase successful for: ${purchase.productID}');
        String receipt = purchase.verificationData.serverVerificationData;
        debugPrint('RECEIPT for purchase : $receipt');
        // এখানে subscription verification & delivery logic add করা যাবে
      }
      if (purchase.pendingCompletePurchase) {
        iap.completePurchase(purchase);
      }
    }
  }
  void buyProduct(ProductDetails product) {

    debugPrint("product: ${product.title}");
    debugPrint("id: ${product.id}");
    debugPrint("price: ${product.price}");
    debugPrint("currency: ${product.currencyCode}");
    debugPrint("description: ${product.description}");
    debugPrint("currency symbol : ${product.currencySymbol}");
    debugPrint("raw Price: ${product.rawPrice}");


    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    // Subscription এর জন্য subscription purchase method call করা হচ্ছে
    iap.buyNonConsumable(purchaseParam: purchaseParam).then((d){
      debugPrint("Purchase status $d");
    });
  }
}