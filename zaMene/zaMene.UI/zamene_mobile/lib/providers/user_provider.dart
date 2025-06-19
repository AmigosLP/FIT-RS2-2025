// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:zamene_mobile/models/user_register_model.dart';
// import 'package:zamene_mobile/providers/auth_provide.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';


// class UserService {
//   static const String _baseUrl = "http://10.0.2.2:5283/";

//   Future<Map<String, dynamic>> login(String username, String password) async {
//     final url = Uri.parse("${_baseUrl}api/Users/login");
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//       },
//       body: jsonEncode({
//         "username": username,
//         "password": password
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final token = data["token"];

//       if (token != null) {
//         AuthProvider.setToken(token);
//         print('Aktiviran token: ${AuthProvider.token}');

//       }
//       final decodedToken = JwtDecoder.decode(token);
      
//       return {
//         "token": token,
//         "username": data["username"],
//         "firstName": data["firstName"],
//         "lastName": data["lastName"]
//       };
//     } else if (response.statusCode == 401) {
//       throw Exception("Neispravni kredencijali");
//     } else {
//       throw Exception("Greška prilikom logina (${response.statusCode})");
//     }
//   }

//   Future <bool> register(UserRegisterModel user) async {
//     final url = Uri.parse("${_baseUrl}api/Users/register");
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//       },
//       body: jsonEncode(user.toJson()),
//     );

//     if (response.statusCode == 200) {
//       return true;
//     } else if (response.statusCode == 400){
//         final errorData = jsonDecode(response.body);
//         throw Exception(errorData["message"] ?? "Greška prilikom registracije");
//     } else {
//         throw Exception("Greška prilikom registracije (${response.statusCode})");
//       }
//   }

//  Future<Map<String, dynamic>> getUserProfile() async {
//   String? token = AuthProvider.token;

//   // Ako token nije u memoriji, pokušaj dohvatiti iz storage-a
//   if (token == null) {
//     final storage = const FlutterSecureStorage();
//     token = await storage.read(key: 'jwt');
//   }

//   if (token == null) {
//     throw Exception("Token nije pronađen. Korisnik nije prijavljen.");
//   }

//   final response = await http.get(
//     Uri.parse('${_baseUrl}api/Users/me'),
//     headers: {
//       'Authorization': 'Bearer $token',
//     },
//   );

//   if (response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else if (response.statusCode == 401) {
//     throw Exception("Niste autorizovani. Molimo prijavite se ponovo.");
//   } else {
//     throw Exception("Greška prilikom dohvata korisničkog profila. (${response.statusCode})");
//   }
// }


//  Map<String, String> createHeaders() {
//   if (AuthProvider.token == null) {
//     throw Exception("Korisnik nije autentificiran");
//   }
//   return {
//     "Content-Type": "application/json",
//     "Authorization": "Bearer ${AuthProvider.token}",
//   };
// }
// Future<int> getUserIdFromToken() async {
//     if (AuthProvider.token == null) throw Exception("Token nije pronađen");
//     final decoded = JwtDecoder.decode(AuthProvider.token!);
//     return int.parse(decoded["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"]);
//   }

//   // Update profila
//   Future<void> updateProfile({
//     required String firstName,
//     required String lastName,
//     required String username,
//     File? profileImage,
//     required int userId,
//   }) async {
//     if (AuthProvider.token == null) throw Exception("Token nije pronađen");

//     final uri = Uri.parse("$_baseUrl/api/Users/profile/$userId");
//     final request = http.MultipartRequest("PUT", uri);

//     request.headers['Authorization'] = "Bearer ${AuthProvider.token}";
//     request.fields['FirstName'] = firstName;
//     request.fields['LastName'] = lastName;
//     request.fields['Username'] = username;

//     if (profileImage != null) {
//       request.files.add(await http.MultipartFile.fromPath(
//         'ProfileImagePath',
//         profileImage.path,
//         contentType: MediaType('image', 'jpeg'), // ili 'png' po potrebi
//       ));
//     }

//     final response = await request.send();

//     if (response.statusCode != 200) {
//       final error = await http.Response.fromStream(response);
//       throw Exception("Greška ${response.statusCode}: ${error.body}");
//     }
//   }

// }
