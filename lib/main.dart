import 'package:flutter/material.dart';
import 'package:provider/provider.dart';         // Provider প্যাকেজ ইমপোর্ট
import 'googlePay/provider/payementProvider.dart';
import 'googlePay/screens/subscriptionView.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Payment',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: SubscriptionScreen(),
    );
  }
}

