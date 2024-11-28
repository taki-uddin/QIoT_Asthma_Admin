import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qiot_admin/constants/api_constants.dart';
import 'dart:html' as html;
import 'package:qiot_admin/helpers/session_storage_helpers.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/services/api/authentication.dart';

class DashboardUsersData {
  static Future<Map<String, dynamic>?> getAllUsersData() async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request =
        http.Request('GET', Uri.parse('${ApiConstants.baseURL}/admin/'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          logger.d('jsonResponse: $jsonResponse');
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        Authentication.signOut();
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserByIdData(String userId) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request =
        http.Request('GET', Uri.parse('${ApiConstants.baseURL}/admin/$userId'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPeakflowhistories(
      String userId, int month, int year) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/peakflowhistories?userId=$userId&month=$month&year=$year'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPeakflowhistoryReport(String userId,
      int startmonth, int startyear, int endmonth, int endyear) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/peakflowhistoryreport?userId=$userId&startmonth=$startmonth&startyear=$startyear&endmonth=$endmonth&endyear=$endyear'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getACThistories(
      String userId, int month, int year) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/acthistories?userId=$userId&month=$month&year=$year'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      logger.d(responseBody);

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadUsersAsthmaActionPlan(
    html.File file,
    String userId,
  ) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/uploadasthmaactionplan/$userId'));

    // Read file bytes
    var reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first; // Wait for file to be loaded
    List<int> fileBytes = reader.result as List<int>;

    // Add the file to the request
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', // The name of the field expected by the server
        fileBytes, // The file bytes
        filename: file.name, // The file name
      ),
    );

    // Add headers to the request
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadEducationalPlan(
    html.File file,
  ) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.MultipartRequest('POST',
        Uri.parse('${ApiConstants.baseURL}/admin/uploadeducationalplan'));

    // Read file bytes
    var reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first; // Wait for file to be loaded
    List<int> fileBytes = reader.result as List<int>;

    // Add the file to the request
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', // The name of the field expected by the server
        fileBytes, // The file bytes
        filename: file.name, // The file name
      ),
    );

    // Add headers to the request
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEducationalPlan() async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET', Uri.parse('${ApiConstants.baseURL}/admin/geteducationalplan'));
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          logger.d('jsonResponse: $jsonResponse');
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return null;
        }
      } else {
        logger.d("error: ${response.reasonPhrase}");
        Authentication.signOut();
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }
}
