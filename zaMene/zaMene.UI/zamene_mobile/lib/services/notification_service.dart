import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:zamene_mobile/models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:5283/api/Notification';

  Map<String, String> createHeaders() {
    if (AuthProvider.token == null || AuthProvider.token!.isEmpty) {
      throw Exception("Korisnik nije autentificiran");
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${AuthProvider.token}",
    };
  }

  Future<List<NotificationModel>> getNotifications() async {
    final headers = createHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/all'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Greška pri dohvaćanju notifikacija: ${response.body}');
    }
  }

Future<bool> markAsRead(int id) async {
    final url = Uri.parse('$baseUrl/mark-as-read/$id');
    final headers = createHeaders();

    final response = await http.post(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Niste autorizirani');
    } else {
      throw Exception('Greška pri označavanju kao pročitano (${response.statusCode}): ${response.body}');
    }
  }

  Future<int> getUnreadNotificationCount(int userId) async {
  final headers = createHeaders();

  final response = await http.get(
    Uri.parse('$baseUrl/unread-count/$userId'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['count'] as int;
  } else {
    throw Exception('Greška pri dohvaćanju broja nepročitanih notifikacija: ${response.body}');
  }
}
}
