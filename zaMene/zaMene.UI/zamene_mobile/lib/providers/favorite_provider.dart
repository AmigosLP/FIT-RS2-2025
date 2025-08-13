import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/providers/auth_provide.dart';

class FavoriteProvider extends ChangeNotifier {
  static const String _base = 'http://10.0.2.2:5283';
  final Set<int> _favoritePropertyIds = {};

  Set<int> get ids => _favoritePropertyIds;
  bool isFavorite(int propertyId) => _favoritePropertyIds.contains(propertyId);

  Map<String, String> _headers() {
    final token = AuthProvider.token;
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Učitaj moje favorite sa backenda (GET /api/Favorite/mine)
  Future<void> syncFromServer() async {
    final res = await http.get(Uri.parse('$_base/api/Favorite/mine'), headers: _headers());
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      _favoritePropertyIds
        ..clear()
        ..addAll(data.map((e) => e['propertyID'] as int));
      notifyListeners();
    } else {
      throw Exception('Greška pri dohvaćanju favorita: ${res.statusCode} ${res.body}');
    }
  }

  /// Toggle (POST /api/Favorite/toggle)
  /// vraća novi status (true ako je postao favorite, false ako je uklonjen)
  Future<bool> toggle(int propertyId) async {
    final body = json.encode({'propertyID': propertyId});
    final res = await http.post(Uri.parse('$_base/api/Favorite/toggle'), headers: _headers(), body: body);

    if (res.statusCode == 200) {
      final map = json.decode(res.body) as Map<String, dynamic>;
      final isFav = map['isFavorite'] == true;
      if (isFav) {
        _favoritePropertyIds.add(propertyId);
      } else {
        _favoritePropertyIds.remove(propertyId);
      }
      notifyListeners();
      return isFav;
    } else {
      throw Exception('Neuspješan toggle favorita: ${res.statusCode} ${res.body}');
    }
  }
}
