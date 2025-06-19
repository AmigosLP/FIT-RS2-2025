import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/models/property_model.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';

class PropertyService {
  static const String baseUrl = 'http://10.0.2.2:5283/'; 

  Map<String, String> createHeaders() {
  if (AuthProvider.token == null || AuthProvider.token!.isEmpty) {
    throw Exception("Korisnik nije autentificiran");
  }
  return {
    "Content-Type": "application/json",
    "Authorization": "Bearer ${AuthProvider.token}",
  };
}


  Future<List<PropertyModel>> getAllProperties() async {
    final headers = createHeaders();
    final response = await http.get(Uri.parse('${baseUrl}api/property/with-images'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body);
      return results.map((json) => PropertyModel.fromJson(json)).toList();
      
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Molimo prijavite se.');

    } else {
      throw Exception('Greška pri dohvaćanju nekretnina (${response.statusCode})');
    }
  }

  Future<double> getAveragePropertyRating(int propertyId) async {
  final headers = createHeaders();
  final url = Uri.parse('${baseUrl}api/Property/$propertyId/average-rating');

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    return double.tryParse(response.body) ?? 0.0;
  } else {
    throw Exception('Greška pri dohvaćanju prosječne ocjene (${response.statusCode})');
  }
}

}
