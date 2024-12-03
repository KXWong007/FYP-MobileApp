import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static String? signedInCustomerId;

  static void setSignedInCustomerId(String customerId) {
    signedInCustomerId = customerId;
  }

  static String? getSignedInCustomerId() {
    return signedInCustomerId;
  }

  static String generateReservationId(String area) {
    // Get current date in YYYYMMDD format for Malaysia timezone
    final now =
        DateTime.now().toUtc().add(Duration(hours: 8)); // Malaysia UTC+8
    final dateStr =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    // Get milliseconds for counter
    final counter = now.millisecondsSinceEpoch
        .toString()
        .substring(now.millisecondsSinceEpoch.toString().length - 2);

    // Get area code based on the full area name
    final areaCode = area.contains('Western') ? 'W' : 'C';

    return "$areaCode$dateStr$counter";
  }

  static Future<Map<String, dynamic>> createReservation({
    required DateTime date,
    required TimeOfDay time,
    required String area,
    required int pax,
  }) async {
    try {
      if (signedInCustomerId == null) {
        throw Exception('No signed-in user found');
      }

      final areaCode = area.contains('Western') ? 'W' : 'C';
      final reservationId = generateReservationId(area);

      final combinedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      final formattedDateTime = "${combinedDateTime.year}-"
          "${combinedDateTime.month.toString().padLeft(2, '0')}-"
          "${combinedDateTime.day.toString().padLeft(2, '0')} "
          "${combinedDateTime.hour.toString().padLeft(2, '0')}:"
          "${combinedDateTime.minute.toString().padLeft(2, '0')}:00";

      print('Sending reservation request:');
      print('ReservationId: $reservationId');
      print('CustomerId: $signedInCustomerId');
      print('DateTime: $formattedDateTime');
      print('Area Code: $areaCode');
      print('Pax: $pax');

      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'customerId': signedInCustomerId,
          'reservationId': reservationId,
          'reservationDate': formattedDateTime,
          'pax': pax,
          'rarea': areaCode,
          'reservedBy': 'customer',
          'rstatus': 'firstc'
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create reservation: ${response.body}');
      }
    } catch (e) {
      print('Error in createReservation: $e');
      throw Exception('Error creating reservation: $e');
    }
  }

  // Validate if the table number exists in the database
  static Future<bool> validateTableNumber(String tableNum) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/validateTable/$tableNum'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists']; // Assuming the response has a field 'exists'
      } else {
        return false; // Table number not found
      }
    } catch (e) {
      throw Exception('Failed to validate table number: $e');
    }
  }
}
