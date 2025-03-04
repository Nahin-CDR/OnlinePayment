import 'dart:async';
import 'dart:convert'; // Base64 decoding এর জন্য import
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionReceiptScreen extends StatefulWidget {
  const SubscriptionReceiptScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SubscriptionReceiptScreenState();
  }
}

class _SubscriptionReceiptScreenState extends State<SubscriptionReceiptScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = false;
  ProductDetails? _subscriptionProduct;
  final String _subscriptionId = 'com.example.testproduct22';

  // Receipt data store করার জন্য variable (Base64 encoded)
  String? _receipt;

  @override
  void initState() {
    super.initState();
    // Purchase updates listen করা হচ্ছে
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchases) {
      _listenToPurchaseUpdated(purchases);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint('Purchase update error: $error');
    });
    _initializeSubscription();
  }

  Future<void> _initializeSubscription() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      setState(() {});
      return;
    }

    // Subscription product details query করা হচ্ছে
    Set<String> ids = {_subscriptionId};
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      debugPrint('Error fetching subscription product: ${response.error}');
    }
    if (response.productDetails.isNotEmpty) {
      setState(() {
        _subscriptionProduct = response.productDetails.first;
      });
    } else {
      debugPrint('No subscription product found');
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        debugPrint('Subscription purchase successful: ${purchase.productID}');
        // Apple থেকে receipt পাওয়ার জন্য verificationData ব্যবহার করা হয়
        String receipt = purchase.verificationData.serverVerificationData;
        setState(() {
          _receipt = receipt;
        });
        // এখানে receipt কে server এ পাঠিয়ে verification করা যেতে পারে
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  // Receipt decode করার function
  String decodeReceipt(String receipt) {
    try {
      final decodedBytes = base64.decode(receipt);
      return utf8.decode(decodedBytes);
    } catch (e) {
      return 'Receipt decode করতে সমস্যা: $e';
    }
  }

  void _buySubscription() {
    if (_subscriptionProduct == null) return;
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: _subscriptionProduct!);
    // Subscription এর জন্য standard purchase method call করা হচ্ছে
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // যদি receipt পাওয়া যায়, তাহলে ডিকোড করা receipt তৈরি করা হবে
    final decodedReceipt = _receipt != null
        ? decodeReceipt(_receipt!)
        : 'কোন receipt পাওয়া যায়নি।';

    return Scaffold(
      appBar: AppBar(
        title: Text('Demo Subscription (1 Week)'),
      ),
      body: Center(
        child: _available && _subscriptionProduct != null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _subscriptionProduct!.title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(_subscriptionProduct!.description),
                    SizedBox(height: 8),
                    Text('Price: ${_subscriptionProduct!.price}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _buySubscription,
                      child: Text('Subscribe Now'),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    Text(
                      'Receipt (Base64 Encoded):',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _receipt ?? 'কোন receipt পাওয়া যায়নি।',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Decoded Receipt:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        decodedReceipt,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              )
            : Text("Subscription service not available or product not loaded"),
      ),
    );
  }
}
