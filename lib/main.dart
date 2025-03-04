import 'package:flutter/material.dart';
import 'package:payments/ApplePay/Screens/singleProductBuy.dart';
import 'package:payments/ApplePay/Widgets/planChanging.dart';
import 'package:payments/ApplePay/Widgets/planChanging2.dart';
import 'package:payments/ApplePay/subscriptionReceipt.dart';
import 'package:provider/provider.dart';
import 'ApplePay/Provider/singlePurchaseProvider.dart';
import 'ApplePay/home.dart';
// Adjust the import path as needed

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SinglePurchaseProvider>(
          create: (context) => SinglePurchaseProvider()..initialize(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Payment',
      home: const SingleProductPurchase(),
    );
  }
}

