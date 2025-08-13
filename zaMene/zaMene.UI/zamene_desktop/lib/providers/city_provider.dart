import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_desktop/models/city_desktop_model.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';

class CityService {
  static const String baseUrl = 'http://localhost:5283/';

  Future<List<CityDesktopModel>> fetchGradove() async {
  final token = AuthProvider.token;

  final response = await http.get(
    Uri.parse('http://localhost:5283/api/City'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    final List<dynamic> jsonList = decoded['resultList'];

    return jsonList
        .map((json) => CityDesktopModel.fromJson(json))
        .toList();
  } else {
    throw Exception('Neuspješno učitavanje gradova: ${response.statusCode}');
  }
}

}
