

import 'package:flutter/material.dart';
import 'package:payments/StripePayment/stripeService.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Home Page'),
            SizedBox(height: 16),
            MaterialButton(
                onPressed: (){
                  StripeService.instance.makePaymentRequest();
                },
              color: Colors.green,
              child: Text("Payment Request"),
            )
          ],
        ),
      ),
    );
  }
}

