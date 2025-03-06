import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isAvailable = false;
  bool _loading = true;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // চেক করুন Google Play Billing সার্ভিস অ্যাপ ডিভাইসে সাপোর্ট করে কিনা
    _isAvailable = await _inAppPurchase.isAvailable();
    if (_isAvailable) {
      await _loadProducts();
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadProducts() async {
    // আপনার প্রকৃত সাবস্ক্রিপশন আইডি বসান
    // যদি একটি সাবস্ক্রিপশন আইডির নিচে একাধিক Base Plan থাকে,
    // সাধারণত একই product ID দিয়েই query করতে পারেন।
    const Set<String> ids = <String>{'test.coins200'};
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(ids);

    if (response.productDetails.isNotEmpty) {
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  void _purchaseSubscription(ProductDetails productDetails) {
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    // সাবস্ক্রিপশনের জন্য সাধারনত buyNonConsumable() ব্যবহৃত হয়
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscription Demo"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _isAvailable
                ? _products.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return _buildSubscriptionCard(product);
                        },
                      )
                    : const Center(
                        child: Text(
                          "No subscription products found.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                : const Center(
                    child: Text(
                      "In-App Purchases are not available.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildSubscriptionCard(ProductDetails product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // সাবস্ক্রিপশনের নাম ও মূল্য
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // সাবস্ক্রিপশনের বর্ণনা
            Text(
              product.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // সাবস্ক্রিপশনের জন্য বোতাম
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.subscriptions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _purchaseSubscription(product),
                label: const Text(
                  "Subscribe Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
