import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/payementProvider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    if (subscriptionProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Subscription Demo")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!subscriptionProvider.isAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text("Subscription Demo")),
        body: const Center(child: Text("In-App Purchases not available.")),
      );
    }

    final products = subscriptionProvider.products;

    return Scaffold(
      appBar: AppBar(title: const Text("Subscription Demo")),
      body: products.isEmpty
          ? const Center(child: Text("No subscription products found."))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.title),
                  subtitle: Text(product.description),
                  trailing: ElevatedButton(
                    onPressed: () {
                      subscriptionProvider.purchaseSubscription(product);
                    },
                    child: Text("Buy ${product.price}"),
                  ),
                );
              },
            ),
    );
  }
}
