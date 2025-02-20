
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:payments/constants/constants.dart';

class StripeService{
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void>makePaymentRequest()async{
    try{
      String? paymentIntentClientSecret = await _createPaymentIntent(10, "usd");

      if(paymentIntentClientSecret == null ) return;

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentClientSecret,
            merchantDisplayName: "Nazmul Haque Nahin"
          )
      );
      await _processPayment();
    } catch(e){
      debugPrint('Error making payment: $e');
    }
  }


  Future<void>_processPayment() async{
    try{
      await Stripe.instance.presentPaymentSheet();
    }catch(e){
      debugPrint('Error presenting payment sheet: $e');
    }
  }


  Future<String?>_createPaymentIntent(int amount,String currency)async{

    try{
      final Dio dio = Dio();
      Map<String,dynamic> data = {
        "amount": _calculatedAmount(amount),
        "currency": currency
      };

      var response = await dio.post(
          "https://api.stripe.com/v1/payment_intents",
          data: data,
          options: Options(
            headers: {
              "Authorization": "Bearer $stripeSecretKey",
              "Content-Type": "application/x-www-form-urlencoded"
            },
            contentType: Headers.formUrlEncodedContentType
          )
      );
      if(response.data != null){
        debugPrint('Payment intent created successfully: ${response.data}');
        return response.data["client_secret"];
      }else{
        debugPrint('Error creating payment intent: No data received from server');
        return null;
      }
    }catch(e){
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }

  String _calculatedAmount(int amount){
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }





}
