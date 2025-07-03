import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_desktop/models/review_desktop_model.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';

class ReviewDesktopService {
  static const String baseUrl = 'http://localhost:5283/';

  Map<String, String> _createHeaders() {
    final token = AuthProvider.token;

    if (token == null || token.isEmpty) {
      throw Exception("Korisnik nije autentificiran (token je null ili prazan)");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<ReviewDesktopModel>> fetchAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api/Review/getAll'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ReviewDesktopModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Neautorizovan pristup - provjerite token.");
      } else {
        throw Exception('Greška pri učitavanju recenzija: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

   Future<void> deleteReview(int reviewId) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}api/review/delete/$reviewId'),
      headers: _createHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška pri brisanju recenzije');
    }
  }

  Future<bool> updateReview(ReviewDesktopModel review) async {
  final url = Uri.parse('${baseUrl}api/Review/Update/${review.reviewID}');
  final body = jsonEncode({
    'rating': review.rating,
    'comment': review.comment,
  });

  final response = await http.put(
    url,
    headers: _createHeaders(),
    body: body,
  );

  return response.statusCode >= 200 && response.statusCode < 300;
}
}
