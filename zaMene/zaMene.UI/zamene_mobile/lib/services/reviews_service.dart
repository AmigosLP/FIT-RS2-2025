import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/models/reviews_create_model.dart';
import 'package:zamene_mobile/models/reviews_model.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';

class ReviewService {
  static const String baseUrl = 'http://10.0.2.2:5283/';

  Map<String, String> createHeaders() {
    if (AuthProvider.token == null || AuthProvider.token!.isEmpty) {
      throw Exception("Korisnik nije autentificiran");
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${AuthProvider.token}",
    };
  }

  Future<List<ReviewModel>> getReviewsByPropertyId(int propertyId) async {
    final headers = createHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}api/review/ByProperty/$propertyId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body);
      return results.map((json) => ReviewModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Molimo prijavite se.');
    } else {
      throw Exception('Greška pri dohvaćanju recenzija (${response.statusCode})');
    }
  }

    Future<void> createReview(ReviewCreateModel review) async {
    final headers = createHeaders();
    final url = Uri.parse('${baseUrl}api/review/create'); // pretpostavljam da je endpoint api/review

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(review.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // uspjeh, recenzija spremljena
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Niste autorizirani. Molimo prijavite se.');
    } else {
      throw Exception(
          'Greška prilikom slanja recenzije (${response.statusCode}): ${response.body}');
    }
  }
}
