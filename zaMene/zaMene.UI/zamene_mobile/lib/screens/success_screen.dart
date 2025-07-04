import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/models/reservation_paypal_model.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:provider/provider.dart';
import 'package:zamene_mobile/providers/notification_provider.dart';
import 'package:zamene_mobile/screens/home_screen.dart';

class SuccessScreen extends StatefulWidget {
  final ReservationPaymentModel reservationData;

  const SuccessScreen({super.key, required this.reservationData});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _isSaving = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    submitReservation();
  }

  Future<void> submitReservation() async {
    try {
      final token = AuthProvider.token;
      if (token == null || token.isEmpty) {
        setState(() {
          _error = "Niste prijavljeni.";
          _isSaving = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5283/api/reservation/Create-custom'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(widget.reservationData.toJson()),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          Provider.of<NotificationProvider>(context, listen: false).fetchUnreadCount();
        }
        setState(() {
          _isSaving = false;
        });
      } else {
        setState(() {
          _error = "Greška pri spremanju rezervacije (${response.statusCode}): ${response.body}";
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Greška: $e";
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                "Uspješno ste izvršili plaćanje!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Povratak na početnu stranicu"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
