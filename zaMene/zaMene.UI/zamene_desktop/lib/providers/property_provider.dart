import 'dart:convert';
import 'dart:io';
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

 Future<bool> updateProperty({
  required int propertyId,
  required Map<String, String> fields,
  required List<File> newImages,
  required List<int> deleteImageIds,
  required String token,
}) async {
  final uri = Uri.parse('http://localhost:5283/api/Property/update/$propertyId');
  final request = http.MultipartRequest('PUT', uri);

  print('PUT $uri');
  print('Token: $token');

  request.headers['Authorization'] = 'Bearer $token';

  print('Fields to send:');
  fields.forEach((key, value) {
    print('  $key: $value');
  });
  request.fields.addAll(fields);

  if (deleteImageIds.isNotEmpty) {
    final deleteJson = jsonEncode(deleteImageIds);
    print('DeleteImageIds: $deleteJson');
    request.fields['DeleteImageIds'] = deleteJson;
  } else {
    print('No images to delete');
  }

  print('New images to upload count: ${newImages.length}');
  for (var i = 0; i < newImages.length; i++) {
    print('Adding new image: ${newImages[i].path}');
    request.files.add(await http.MultipartFile.fromPath('NewImages', newImages[i].path));
  }

  final response = await request.send();
  final respStr = await response.stream.bytesToString();

  print('Response status code: ${response.statusCode}');
  print('Response body: $respStr');

  return response.statusCode >= 200 && response.statusCode < 300;
}

}
