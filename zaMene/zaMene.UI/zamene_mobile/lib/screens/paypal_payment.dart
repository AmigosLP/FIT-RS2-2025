import 'package:flutter/material.dart';

class PaypalPaymentScreen extends StatelessWidget {
  final Map<String, dynamic> nekretnina;

  const PaypalPaymentScreen({super.key, required this.nekretnina});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plaćanje PayPal"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Integracija s PayPal ovdje..."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Nazad"),
            )
          ],
        ),
      ),
    );
  }
}
