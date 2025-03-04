import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Subscription3PlansScreen extends StatefulWidget {
  const Subscription3PlansScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Subscription3PlansScreenState();
  }
}

class _Subscription3PlansScreenState extends State<Subscription3PlansScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = false;
  List<ProductDetails> _products = [];

  // App Store Connect e configure kora ৩টি subscription er product IDs
  final Set<String> _productIds = {
    'com.example.starter',
    'com.example.gold',
    'com.example.platinum',
  };

  @override
  void initState() {
    super.initState();
    _initialize();
    // Purchase updates listen kora hocche
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchases) {
      _listenToPurchaseUpdated(purchases);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint('Purchase update error: $error');
    });
  }

  Future<void> _initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      setState(() {});
      return;
    }
    // Query the product details for the given product IDs
    ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint('Error fetching products: ${response.error}');
    }
    if (response.productDetails.isNotEmpty) {
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        debugPrint('Purchase successful for: ${purchase.productID}');
        // Ekhane subscription verification & delivery logic add kora jabe
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    // Subscription er jonno subscription purchase method call kora hocche
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Ei function ta product id theke plan name ber kore
  String _getPlanName(String productId) {
    if (productId.contains('starter')) {
      return 'Starter';
    } else if (productId.contains('gold')) {
      return 'Gold';
    } else if (productId.contains('platinum')) {
      return 'Platinum';
    }
    return 'Plan';
  }

  // Attractive subscription card widget
  Widget _buildSubscriptionCard(ProductDetails product) {
    String planName = _getPlanName(product.id);
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan title
            Text(
              planName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Plan description (product description)
            Text(
              product.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            // Price and Subscribe button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.price,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _buyProduct(product),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Subscribe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
        title: Text('Subscription Plans'),
      ),
      body: _available
          ? _products.isNotEmpty
              ? ListView(
                  children: _products
                      .map((product) => _buildSubscriptionCard(product))
                      .toList(),
                )
              : Center(child: CircularProgressIndicator())
          : Center(child: Text('In-App Purchases not available')),
    );
  }
}
