import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:qiot_admin/constants/api_constants.dart';
import 'package:qiot_admin/helpers/session_storage_helpers.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/models/medication/medication_models.dart';
import 'package:qiot_admin/services/auth_session.dart';

class MedicationApi {
  static Future<void> _rejectIfUnauthorized(int statusCode) async {
    await AuthSession.rejectIfUnauthorized(statusCode);
  }

  static Future<MedicationCatalog> getCatalog() async {
    final token = await SessionStorageHelpers.getStorage('accessToken');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseURL}/medications/catalog'),
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        if (decoded['payload'] != null) {
          return MedicationCatalog.fromJson(
            Map<String, dynamic>.from(decoded['payload'] as Map),
          );
        }
      }
    } catch (e) {
      logger.d('Medication catalog API failed, using bundled fallback: $e');
    }
    return _loadBundledCatalog();
  }

  static Future<MedicationCatalog> _loadBundledCatalog() async {
    final raw =
        await rootBundle.loadString('assets/data/medication-catalog.json');
    return MedicationCatalog.fromJson(
      json.decode(raw) as Map<String, dynamic>,
    );
  }

  static Future<Map<String, dynamic>?> updateUserMedications(
    String userId,
    List<Map<String, dynamic>> medications,
  ) async {
    final token = await SessionStorageHelpers.getStorage('accessToken');
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseURL}/user/$userId/medications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'medications': medications,
          'requirePreventer': true,
          'requireReliever': true,
        }),
      );

      if (response.body.isEmpty) {
        await _rejectIfUnauthorized(response.statusCode);
        return null;
      }

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      await _rejectIfUnauthorized(response.statusCode);
      return decoded;
    } catch (e) {
      logger.d('Failed to update user medications: $e');
      return null;
    }
  }
}
