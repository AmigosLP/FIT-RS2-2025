import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_desktop/models/property_statistics_model.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';

class PropertyStatisticsService {
  static const String baseUrl = 'http://localhost:5283/';

  Map<String, String> _createHeaders() {
    final token = AuthProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception("Token nije dostupan.");
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<PropertyStatisticsModel>> fetchStatistics() async {
    final response = await http.get(
      Uri.parse('${baseUrl}api/property/statistics'),
      headers: _createHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => PropertyStatisticsModel.fromJson(e)).toList();
    } else {
      throw Exception('Greška prilikom dohvata statistike: ${response.statusCode}');
    }
  }
}
