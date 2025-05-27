import 'package:flutter/material.dart';
import 'package:zamene_mobile/screens/paypal_payment.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> nekretnina;

  const PaymentScreen({super.key, required this.nekretnina});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;

  Future<void> _selectDate({required bool isCheckIn}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nekretnina = widget.nekretnina;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plaćanje"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informacije o nekretnini
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nekretnina['naziv'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(nekretnina['adresa'],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(nekretnina['cijena'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Period", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(checkInDate != null
                        ? "${checkInDate!.day}.${checkInDate!.month}.${checkInDate!.year}"
                        : "Check In"),
                    onPressed: () => _selectDate(isCheckIn: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(checkOutDate != null
                        ? "${checkOutDate!.day}.${checkOutDate!.month}.${checkOutDate!.year}"
                        : "Check Out"),
                    onPressed: () => _selectDate(isCheckIn: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: const [
                Text("Metoda plaćanja",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text("Detalji", style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCard(
                      number: "•••• 1222",
                      balance: "\$31,250",
                      color: Colors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCard(
                      number: "••••••an@ email.com",
                      balance: "\$12,290",
                      color: Colors.deepPurple),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaypalPaymentScreen(nekretnina: nekretnina),
                    ),
                  );
                },
                icon: const Icon(Icons.payment),
                label: const Text("Plati putem PayPal"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      {required String number,
      required String balance,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Balance",
              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          Text(balance,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
