// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
//
// class SubscriptionScreen extends StatefulWidget {
//   const SubscriptionScreen({super.key});
//
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return _SubscriptionScreenState();
//   }
// }
//
// class _SubscriptionScreenState extends State<SubscriptionScreen> {
//   final InAppPurchase _iap = InAppPurchase.instance;
//   late StreamSubscription<List<PurchaseDetails>> _subscription;
//   bool _available = false;
//   ProductDetails? _subscriptionProduct;
//   final String _subscriptionId = 'com.example.demosubscription.week';
//
//   @override
//   void initState() {
//     super.initState();
//     // Listen to purchase updates
//     final purchaseUpdated = _iap.purchaseStream;
//     _subscription = purchaseUpdated.listen((purchases) {
//       _listenToPurchaseUpdated(purchases);
//     }, onDone: () {
//       _subscription.cancel();
//     }, onError: (error) {
//       debugPrint('Purchase update error: $error');
//     });
//     _initializeSubscription();
//   }
//
//   Future<void> _initializeSubscription() async {
//     _available = await _iap.isAvailable();
//     if (!_available) {
//       setState(() {});
//       return;
//     }
//
//     // Query subscription product details
//     Set<String> ids = {_subscriptionId};
//     ProductDetailsResponse response = await _iap.queryProductDetails(ids);
//     if (response.error != null) {
//       print('Error fetching subscription product: ${response.error}');
//     }
//     if (response.productDetails.isNotEmpty) {
//       setState(() {
//         _subscriptionProduct = response.productDetails.first;
//       });
//     } else {
//       print('No subscription product found');
//     }
//   }
//
//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
//     for (var purchase in purchaseDetailsList) {
//       if (purchase.status == PurchaseStatus.purchased) {
//         print('Subscription purchase successful: ${purchase.productID}');
//         // Here, add your subscription validation & delivery logic
//       }
//       if (purchase.pendingCompletePurchase) {
//         _iap.completePurchase(purchase);
//       }
//     }
//   }
//
//   void _buySubscription() {
//     if (_subscriptionProduct == null) return;
//     final PurchaseParam purchaseParam = PurchaseParam(productDetails: _subscriptionProduct!);
//     // For subscriptions, use the standard purchase method
//     _iap.buyNonConsumable(purchaseParam: purchaseParam);
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Demo Subscription (1 Week)'),
//       ),
//       body: Center(
//         child: _available && _subscriptionProduct != null
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(_subscriptionProduct!.title),
//                   Text(_subscriptionProduct!.description),
//                   Text('Price: ${_subscriptionProduct!.price}'),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _buySubscription,
//                     child: Text('Subscribe Now'),
//                   ),
//                 ],
//               )
//             : Text("Subscription service not available or product not loaded"),
//       ),
//     );
//   }
// }
