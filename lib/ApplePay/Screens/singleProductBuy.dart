import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:payments/ApplePay/Provider/singlePurchaseProvider.dart';

class SingleProductPurchase extends StatefulWidget {
  const SingleProductPurchase({super.key});

  @override
  State<SingleProductPurchase> createState() => _SingleProductPurchaseState();
}

class _SingleProductPurchaseState extends State<SingleProductPurchase> {
  late SinglePurchaseProvider purchaseProvider;

  @override
  void initState() {
    super.initState();
    // Initialize the provider without listening to context changes.
    purchaseProvider = Provider.of<SinglePurchaseProvider>(context, listen: false);
    // Call your provider's initialization method, if available.
    purchaseProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In-App Purchase Demo'),
        centerTitle: true,
      ),
      body: Consumer<SinglePurchaseProvider>(
        builder: (context, provider, child) {
          if (!provider.available) {
            return const Center(
              child: Text(
                "In-App Purchase service not available",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh the products list (assuming loadProducts exists)
              await provider.loadProducts();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Available Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...provider.products.map(
                      (product) => Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        product.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(product.description),
                      ),
                      trailing: SizedBox(
                        width: 80, // Set a fixed width for the trailing widget
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.price,
                              style: const TextStyle(fontSize: 16, color: Colors.green),
                            ),
                            const SizedBox(height: 4),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => provider.buyProduct(product),
                              child: const Text(
                                'Buy',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),


                const Divider(),
                const Text(
                  'Purchase History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ...provider.purchases.map(
                      (purchase) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Purchase: ${purchase.productID}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        'Status: ${purchase.status}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
