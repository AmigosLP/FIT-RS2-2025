import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/providers/auth_provide.dart';

class FavoriteService {
  static const String baseUrl = 'http://10.0.2.2:5283/api/Favorite';

  Map<String, String> _headers() {
    final token = AuthProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception("Niste prijavljeni.");
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<int>> getMyFavoritePropertyIds() async {
    final res = await http.get(Uri.parse('$baseUrl/mine'), headers: _headers());
    if (res.statusCode != 200) {
      throw Exception('Greška: ${res.body}');
    }
    final List<dynamic> data = json.decode(res.body);
    return data.map<int>((f) => f['propertyID'] as int).toList();
  }

  Future<bool> toggle(int propertyId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/toggle'),
      headers: _headers(),
      body: json.encode({'propertyID': propertyId}),
    );
    if (res.statusCode != 200) {
      throw Exception('Greška: ${res.body}');
    }
    final obj = json.decode(res.body);
    return obj['isFavorite'] == true;
  }
}
