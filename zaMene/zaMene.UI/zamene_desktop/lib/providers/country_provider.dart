import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_desktop/models/country_desktop_model.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';

class CountryService {
  static const String baseUrl = 'http://localhost:5283/';

  Future<List<CountryDesktopModel>> fetchCountries() async {
    final token = AuthProvider.token;

    final response = await http.get(
      Uri.parse('${baseUrl}api/Country'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> jsonList = decoded['resultList'];
      return jsonList.map((e) => CountryDesktopModel.fromJson(e)).toList();
    } else {
      throw Exception('Neuspješno učitavanje država: ${response.statusCode}');
    }
  }
}
