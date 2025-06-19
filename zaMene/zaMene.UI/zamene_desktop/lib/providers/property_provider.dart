import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_desktop/models/property_model.dart';

class NekretnineService {
  Future<List<PropertyModel>> fetchNekretnine() async {
    final response = await http.get(Uri.parse('http://localhost:5283/api/Property/with-images'));

    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((json) => PropertyModel.fromJson(json)).toList();
    } else {
      throw Exception('Neuspješno učitavanje nekretnina');
    }
  }
}
