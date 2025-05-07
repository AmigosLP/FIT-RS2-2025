import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';

class UserProvider {

  static String? _baseUrl;
  UserProvider(){
    _baseUrl = const String.fromEnvironment("baseUrl", defaultValue: "http://localhost:5283/");
  }

  Future<dynamic> get() async {
    var url = "${_baseUrl}api/Users";
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: createHeaders());

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return data;
      } else (
        throw new Exception("Unknown exception")
      );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("${_baseUrl}api/Users/login?username=$username&password=$password");
    final response = await http.post(url); // BE koristi POST

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception("Neispravni kredencijali");
    } else {
      throw Exception("Greška prilikom logina (${response.statusCode})");
  }
}

  bool isValidResponse(Response response) {
    if(response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unathorized");
    } else {
      throw new Exception("Something went wrong");
    }
  }

    Map<String, String> createHeaders() {
      String username = AuthProvider.username!;
      String password = AuthProvider.password!;

      String basicAuth = "Basic ${base64Encode(utf8.encode('$username:$password'))}";

      var headers = {
        "Content-Type": "application/json",
        "Authorization": basicAuth
      };

      return headers;
    }
}