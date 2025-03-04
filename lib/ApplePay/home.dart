import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseDemo extends StatefulWidget {
  const InAppPurchaseDemo({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _InAppPurchaseDemoState();
  }
}

class _InAppPurchaseDemoState extends State<InAppPurchaseDemo> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  // Ei product ID ti apnar App Store Connect ba Play Console e configure kora thakte hobe.
  final String _productId =
      'com.example.testproduct2'; //'com.example.testproduct';

  @override
  void initState() {
    super.initState();
    // Purchase update stream listen koro
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchases) {
      _listenToPurchaseUpdated(purchases);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // error handle koro
      print('Error in purchase stream: $error');
    });
    _initialize();
  }

  Future<void> _initialize() async {
    // Check koro in-app purchase available kina
    _available = await _iap.isAvailable();
    if (!_available) {
      setState(() {});
      return;
    }

    // Product details query koro
    Set<String> ids = {_productId};
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      print('Error fetching products: ${response.error}');
    }
    if (response.productDetails.isEmpty) {
      print('No products found');
    }
    setState(() {
      _products = response.productDetails;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Ei jaygay purchase verify kore product deliver korte paro
        print('Purchase successful: ${purchase.productID}');
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
    setState(() {
      _purchases = purchaseDetailsList;
    });
  }

  void _buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    // Consumable purchase er jonno buyConsumable() use kora hoy
    _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('In-App Purchase Demo'),
      ),
      body: _available
          ? ListView(
              children: [
                ..._products.map((product) => ListTile(
                      title: Text(product.title),
                      subtitle: Text(product.description),
                      trailing: Text(product.price),
                      onTap: () => _buyProduct(product),
                    )),
                Divider(),
                ..._purchases.map((purchase) => ListTile(
                      title: Text('Purchase: ${purchase.productID}'),
                      subtitle: Text(purchase.status.toString()),
                    )),
              ],
            )
          : Center(
              child: Text("In-App Purchase service not available"),
            ),
    );
  }
}
