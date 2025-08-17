// lib/services/admin_support_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:zamene_desktop/models/support_ticket_model.dart';

class AdminSupportService {
  static const _storage = FlutterSecureStorage();

  String get _baseUrl =>
      Platform.isAndroid ? "http://10.0.2.2:5283" : "http://localhost:5283";

  Future<Map<String, String>> _authHeader() async {
    final token = await _storage.read(key: "token");
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  /// Helper: backend nekad vrati List, a nekad objekat sa resultList/items/data...
  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final k in const ["resultList", "items", "result", "data", "value"]) {
        final v = decoded[k];
        if (v is List) return v;
      }
    }
    return const [];
  }

  /// Ostavljen isti naziv koji koristiš na ekranu.
  /// Filtriranje po statusu i subject-u.
  Future<List<SupportTicketModel>> getTickets({bool? resolved, String? subject}) async {
    final headers = await _authHeader();

    final qp = <String, String>{};
    if (resolved != null) qp['IsResolved'] = resolved.toString();
    if (subject != null && subject.trim().isNotEmpty) qp['Subject'] = subject.trim();
    // Ne šaljemo "Search" parametar (imao je 400).

    final uri = Uri.parse("$_baseUrl/api/SupportTicket")
        .replace(queryParameters: qp.isEmpty ? null : qp);

    final res = await http.get(uri, headers: headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET tickets failed (${res.statusCode}): ${res.body}'.trim());
    }

    final decoded = jsonDecode(res.body);
    final list = _extractList(decoded);

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => SupportTicketModel.fromJson(e))
        .toList();
  }

  /// Ostavljen isti naziv koji već koristiš za slanje odgovora.
  Future<bool> respond({
    required int ticketId,
    required String responseText,
    bool resolve = true,
  }) async {
    final headers = await _authHeader();

    final uri = Uri.parse("$_baseUrl/api/SupportTicket/$ticketId");
    final body = jsonEncode({
      "response": responseText,
      "isResolved": resolve,
    });

    final res = await http.put(uri, headers: headers, body: body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Respond failed (${res.statusCode}): ${res.body}'.trim());
    }
    return true;
  }

  /// NOVO: metoda koju tvoj UI već zove kod toggle-a "Riješen".
  Future<bool> updateTicket({
    required int ticketId,
    required bool isResolved,
  }) async {
    final headers = await _authHeader();

    final uri = Uri.parse("$_baseUrl/api/SupportTicket/$ticketId");
    final body = jsonEncode({
      "isResolved": isResolved,
      // response ostavljamo nedirnut (null) – backend Update prima partial DTO
    });

    final res = await http.put(uri, headers: headers, body: body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('UpdateTicket failed (${res.statusCode}): ${res.body}'.trim());
    }
    return true;
  }
}
