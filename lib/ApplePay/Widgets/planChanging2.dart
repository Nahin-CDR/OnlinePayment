import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Subscription3PlansChangeScreen2 extends StatefulWidget {
  const Subscription3PlansChangeScreen2({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Subscription3PlansScreenState();
  }
}

class _Subscription3PlansScreenState extends State<Subscription3PlansChangeScreen2> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = false;
  List<ProductDetails> _products = [];

  // App Store Connect এ configure করা ৩টি subscription এর product IDs
  final Set<String> _productIds = {
    'com.example.starter',
    'com.example.gold',
    'com.example.platinum',
  };

  // বর্তমান সক্রিয় সাবস্ক্রিপশন প্ল্যান
  String? _currentPlan;

  // সাবস্ক্রিপশন প্ল্যানগুলোর ক্রমানুসারে অর্ডার
  final Map<String, int> _planOrder = {
    'Starter': 1,
    'Gold': 2,
    'Platinum': 3,
  };

  @override
  void initState() {
    super.initState();
    _initialize();
    // Purchase updates listen করা হচ্ছে
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
    ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
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
        // এখানে subscription verification & delivery logic add করা যাবে
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  // সাবস্ক্রিপশন পরিবর্তনের (Subscribe / Upgrade / Downgrade) জন্য ফাংশন
  void _changeSubscription(ProductDetails product) {
    debugPrint("product: ${product.title}");
    debugPrint("id: ${product.id}");
    debugPrint("price: ${product.price}");
    debugPrint("currency: ${product.currencyCode}");
    debugPrint("description: ${product.description}");
    debugPrint("currency symbol : ${product.currencySymbol}");
    debugPrint("raw Price: ${product.rawPrice}");



    String selectedPlan = _getPlanName(product.id);

    String message = '';

    if (_currentPlan == null) {
      // কোন সাবস্ক্রিপশন নাই, সরাসরি নতুন সাবস্ক্রিপশন নেওয়া হবে
      _currentPlan = selectedPlan;
      message = 'আপনি $selectedPlan প্ল্যানে সাবস্ক্রিপশন শুরু করেছেন।';
    } else if (_currentPlan == selectedPlan) {
      // একই প্ল্যানে পুনরায় সাবস্ক্রাইব করতে চাইলে
      message = 'আপনি ইতিমধ্যে $selectedPlan প্ল্যানে আছেন।';
    } else {
      // সাবস্ক্রিপশন পরিবর্তন: আপগ্রেড অথবা ডাউগ্রেড
      int currentOrder = _planOrder[_currentPlan!] ?? 0;
      int newOrder = _planOrder[selectedPlan] ?? 0;
      if (newOrder > currentOrder) {
        // Upgrade: নতুন প্ল্যান তাৎক্ষণিকভাবে সক্রিয় হবে
        _currentPlan = selectedPlan;
        message = 'আপগ্রেড সফল! ${_currentPlan!} প্ল্যান তৎক্ষণাৎ সক্রিয় হয়েছে।';
      } else {
        // Downgrade: বর্তমান বিলিং চক্র শেষে কার্যকর হবে
        _currentPlan = selectedPlan;
        message = 'ডাউগ্রেড সফল! ${_currentPlan!} প্ল্যান পরবর্তী বিলিং চক্র থেকে কার্যকর হবে।';
      }
    }

    // ফলাফল দেখানোর জন্য SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  // Return an icon based on the plan
  Widget _getPlanIcon(String productId) {
    if (productId.contains('starter')) {
      return Icon(Icons.emoji_emotions, size: 50, color: Colors.blue);
    } else if (productId.contains('gold')) {
      return Icon(Icons.stars, size: 50, color: Colors.amber);
    } else if (productId.contains('platinum')) {
      return Icon(Icons.auto_awesome, size: 50, color: Colors.purple);
    }
    return Icon(Icons.subscriptions, size: 50);
  }

  // Attractive subscription card widget with Icon instead of image
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
            // Display plan icon
            Center(child: _getPlanIcon(product.id)),
            SizedBox(height: 12),
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
            // Price and Change Subscription button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.price,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _changeSubscription(product),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Change Plan'),
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
