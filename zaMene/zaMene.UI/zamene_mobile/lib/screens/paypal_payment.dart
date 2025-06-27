import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/models/reservation_paypal_model.dart';
import 'package:zamene_mobile/screens/success_screen.dart';
import 'package:zamene_mobile/screens/cancel_screen.dart';

class PaypalPaymentScreen extends StatefulWidget {
  final ReservationPaymentModel reservationData;

  const PaypalPaymentScreen({super.key, required this.reservationData});

  @override
  State<PaypalPaymentScreen> createState() => _PaypalPaymentScreenState();
}

class _PaypalPaymentScreenState extends State<PaypalPaymentScreen> {
  bool isLoading = true;

  final String clientId = 'Ad-zdCeWSSof3F1LvD51A5o4fV-coqy-zS0Ci9rddmfBhbQtKb9S67yAUEioR0QCxGjUMuS66SJwfpy6';
  final String clientSecret = 'ECz7SzoFRvBmjgvc8HdMFn8S6spTauoxXM_IhKfW5tR2VowwzwwZ0taNjgHqi69BFKPSg14ue8GxRzZ9';
  final String _payPalBaseUrl = 'https://api.sandbox.paypal.com';

  @override
  void initState() {
    super.initState();
    startPaymentProcess();
  }

  Future<String> getAccessToken() async {
    final response = await http.post(
      Uri.parse('$_payPalBaseUrl/v1/oauth2/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Neuspješno dobavljanje PayPal access token-a');
    }
  }

  Future<String> createPayment(String accessToken, double total) async {
    final response = await http.post(
      Uri.parse('$_payPalBaseUrl/v2/checkout/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'intent': 'CAPTURE',
        'purchase_units': [
          {
            'amount': {
              'currency_code': 'EUR',
              'value': total.toStringAsFixed(2),
            },
          },
        ],
        'application_context': {
          'return_url': 'https://your-success-url.com',
          'cancel_url': 'https://your-cancel-url.com',
        }
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final approvalUrl = data['links'].firstWhere((link) => link['rel'] == 'approve')['href'];
      return approvalUrl;
    } else {
      throw Exception('Neuspješno kreiranje PayPal narudžbe');
    }
  }

  Future<void> startPaymentProcess() async {
    try {
      final accessToken = await getAccessToken();
      final orderUrl = await createPayment(accessToken, widget.reservationData.totalPrice);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaypalWebViewScreen(
            approvalUrl: orderUrl,
            reservationData: widget.reservationData,
          ),
        ),
      );
    } catch (e) {
      print("Greška: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri pokretanju PayPal plaćanja")),
      );
      Navigator.of(context).pop(); // Vraćaj se nazad ako dođe do greške
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// OVDJE IDE NOVI EKRAN KOJI PRIKAZUJE WEBVIEW

class PaypalWebViewScreen extends StatelessWidget {
  final String approvalUrl;
  final ReservationPaymentModel reservationData;

  const PaypalWebViewScreen({
    super.key,
    required this.approvalUrl,
    required this.reservationData,
  });

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.startsWith('https://your-success-url.com')) {
              Future.delayed(const Duration(milliseconds: 300), () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SuccessScreen(reservationData: reservationData),
                  ),
                );
              });
              return NavigationDecision.prevent;
            }

            if (url.startsWith('https://your-cancel-url.com')) {
              Future.delayed(const Duration(milliseconds: 300), () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const CancelScreen(),
                  ),
                );
              });
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(approvalUrl));

    return Scaffold(
      appBar: AppBar(title: const Text("PayPal Plaćanje")),
      body: WebViewWidget(controller: controller),
    );
  }
}
