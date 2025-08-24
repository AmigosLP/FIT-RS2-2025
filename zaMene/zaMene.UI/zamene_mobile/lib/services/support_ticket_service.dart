import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:zamene_mobile/models/support_ticket_model.dart';

class SupportTicketService {
  static const String baseUrl = 'http://10.0.2.2:5283/api/SupportTicket';

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthProvider.token}',
      };

  Future<SupportTicketModel> createTicket({
    required String subject,
    required String message,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: _headers(),
      body: jsonEncode({'subject': subject, 'message': message}),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Greška pri kreiranju tiketa: ${resp.body}');
    }

    final Map<String, dynamic> jsonMap = jsonDecode(resp.body);
    return SupportTicketModel.fromJson(jsonMap);
  }

  Future<List<SupportTicketModel>> getMyTickets() async {
    final resp = await http.get(Uri.parse('$baseUrl/mine'), headers: _headers());

    if (resp.statusCode != 200) {
      throw Exception('Greška pri dohvaćanju tiketa: ${resp.body}');
    }

    final List<dynamic> list = jsonDecode(resp.body);
    return list
        .map((e) => SupportTicketModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
