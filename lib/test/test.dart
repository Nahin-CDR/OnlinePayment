
import 'package:flutter/material.dart';

class MathUtils {
  // Private constructor to prevent object creation
  MathUtils._();

  // Static method for addition
  static int add(int a, int b) => a + b;

  // Static method for subtraction
  static int subtract(int a, int b) => a - b;
}

class Stripe{
  Stripe._();
  // make single instance to be used
  static final Stripe instance = Stripe._();



}


void main() {
  // Using static methods without instantiating the class
  //debugPrint("${MathUtils.add(5, 3)}");      // Output: 8
  //debugPrint("${MathUtils.subtract(10, 4)}"); // Output: 6
// Get the singleton instance
  var stripe1 = Stripe1.instance;

  // Initialize Stripe (optional setup)
  stripe1.initialize();

  // Process a payment
  stripe1.processPayment("4242 4242 4242 4242", 50.0);
   //var obj = MathUtils();
   // ❌ This will cause an error because constructor is private

}
class Stripe1 {
  // Private constructor
  Stripe1._();

  // Singleton instance
  static final Stripe1 instance = Stripe1._();

  // Simulated function to initialize Stripe
  void initialize() {
    print("🔹 Stripe Initialized.");
  }

  // Simulated function to process a payment
  Future<void> processPayment(String cardNumber, double amount) async {
    print("💳 Processing payment of \$$amount using card: $cardNumber...");
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    print("✅ Payment of \$$amount successful!");
  }
}


