import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zamene_mobile/models/reservation_model.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:flutter/material.dart';

class ReservationService {
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

  Future<List<ReservationModel>> getActiveReservations(int propertyId) async {
    final headers = createHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}api/reservation/active-reservations/$propertyId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body);
      return results.map((e) => ReservationModel.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri učitavanju rezervacija (${response.statusCode})');
    }
  }

  Future<ReservationModel> checkAvailability({
    required int propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final headers = createHeaders();

    final url = Uri.parse(
      '${baseUrl}api/reservation/check-availability'
      '?propertyId=$propertyId'
      '&startDate=${startDate.toIso8601String()}'
      '&endDate=${endDate.toIso8601String()}',
    );

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ReservationModel.fromJson(json);
    } else {
      throw Exception('Greška pri provjeri dostupnosti (${response.statusCode})');
    }
  }

  Future<List<DateTimeRange>> getZauzetiTermini(int propertyId) async {
    final headers = createHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}api/reservation/active-reservations/$propertyId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body);
      return results.map((json) {
        final start = DateTime.parse(json['startDate']);
        final end = DateTime.parse(json['endDate']);
        return DateTimeRange(start: start, end: end);
      }).toList();
    } else {
      throw Exception('Greška pri učitavanju zauzetih termina (${response.statusCode})');
    }
  }
}
