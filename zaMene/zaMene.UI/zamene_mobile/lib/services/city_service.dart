import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:zamene_mobile/models/city_model.dart';

class CityService {
  static const String baseUrl = 'http://10.0.2.2:5283/api/City';

  Map<String, String> createHeaders() {
    if (AuthProvider.token == null || AuthProvider.token!.isEmpty) {
      throw Exception("Korisnik nije autentificiran");
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${AuthProvider.token}",
    };
  }

  Future<List<City>> getCities() async {
    final headers = createHeaders();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => City.fromJson(json)).toList();
    } else {
      throw Exception('Greška pri dohvaćanju gradova: ${response.body}');
    }
  }
}
