import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/providers/auth_provide.dart';


class UserService {
  static const String _baseUrl = "http://10.0.2.2:5283/";

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("${_baseUrl}api/Users/login?username=$username&password=$password");
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Neispravni kredencijali");
    } else {
      throw Exception("Greška prilikom logina (${response.statusCode})");
    }
  }

  Map<String, String> createHeaders() {
    final basicAuth = 'Basic ${base64Encode(utf8.encode('${AuthProvider.username}:${AuthProvider.password}'))}';
    return {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
  }
}
