import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:zamene_desktop/models/property_model.dart';

class NekretnineService {
  String get _base => Platform.isAndroid ? 'http://10.0.2.2:5283' : 'http://localhost:5283';

  Future<List<PropertyModel>> fetchNekretnine({String? token}) async {
    final uri = Uri.parse('$_base/api/Property/with-images');
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((json) => PropertyModel.fromJson(json)).toList();
    } else {
      throw Exception('Neuspješno učitavanje nekretnina');
    }
  }

  Future<bool> updateProperty({
    required int propertyId,
    required Map<String, String> fields,
    required List<File> newImages,
    required List<int> deleteImageIds,
    required String token,
  }) async {
    final uri = Uri.parse('$_base/api/Property/update/$propertyId');
    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = 'Bearer $token';

    String normNum(String v) => v.replaceAll(',', '.').trim();
    if (fields.containsKey('Price')) fields['Price'] = normNum(fields['Price']!);
    if (fields.containsKey('Area')) fields['Area'] = normNum(fields['Area']!);

    request.fields.addAll(fields);

    for (int i = 0; i < deleteImageIds.length; i++) {
      request.fields['DeleteImageIds[$i]'] = deleteImageIds[i].toString();
    }

    for (final f in newImages) {
      request.files.add(await http.MultipartFile.fromPath('NewImages', f.path));
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
