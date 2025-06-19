import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:zamene_desktop/exceptions/not_admin_exception.dart';
import 'package:zamene_desktop/models/login_model.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';


class UserProvider {
  static String? _baseUrl;
  final _secureStorage = const FlutterSecureStorage();

  UserProvider(){
    _baseUrl = const String.fromEnvironment("baseUrl", defaultValue: "http://localhost:5283/");
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: "token");
  }

  Future<dynamic> get() async {
    var url = "${_baseUrl}api/Users";
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: createHeaders());

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return data;
      } else {
        (
        throw Exception("Unknown exception")
      );
      }
  }

 Future<void> userLogin(LoginModel model) async {
  final url = "${_baseUrl}api/Users/Login";
  final uri = Uri.parse(url);

  try {
    final jsonRequest = jsonEncode(model.toJson());
    final response = await http.post(
      uri,
      body: jsonRequest,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (isValidResponse(response)) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['token'];

      if (token == null || token.isEmpty) {
        throw Exception("Login failed: no token received.");
      }

      final payload = JwtDecoder.decode(token);

      String userRole = payload.entries.firstWhere(
        (e) => e.key.toLowerCase().contains('role'),
        orElse: () => MapEntry('role', ''),
      ).value;

      if (userRole.toLowerCase() != 'admin') {
        throw NotAdminException("Moraš biti admin da bi pristupio ovoj aplikaciji.");
      }

      // Spremi token ako je admin
      await _secureStorage.write(key: 'token', value: token);

    } else {
      throw Exception("Invalid username or password.");
    }
  } catch (e) {
    // samo rethrow, da ne wrapaš grešku u novi Exception
    rethrow;
  }
}



bool isValidResponse(http.Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return true;
  } else if (response.statusCode >= 400 && response.statusCode < 500) {
    final errorBody = jsonDecode(response.body);
    final message =
        errorBody['message'] ?? "Something went wrong. Please try again.";
    throw message;
  } else if (response.statusCode >= 500) {
    var messageErr =
        "Something went wrong on our side. Please try again later.";
    throw messageErr;
  } else {
    var expMessage = "Unexpected error. Please try again.";
    throw expMessage;
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