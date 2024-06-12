import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:qiot_admin/helpers/session_storage_helpers.dart';

class DashboardUsersData {
  static Future<Map<String, dynamic>?> getAllUsersData() async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('token')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1/admin/'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          print('Response body is empty or null');
          return null;
        }
      } else {
        print("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserByIdData(String userId) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('token')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1/admin/$userId'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          return jsonResponse;
        } else {
          print('Response body is empty or null');
          return null;
        }
      } else {
        print("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print('error: Failed to make HTTP request: $e');
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
          'Bearer ${await SessionStorageHelpers.getStorage('token')}',
    };

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1/admin/uploadasthmaactionplan/$userId'));

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
          print('Response body is empty or null');
          return null;
        }
      } else {
        print("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadEducationalPlan(
    html.File file,
  ) async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('token')}',
    };

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1/admin/uploadeducationalplan'));

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
          print('Response body is empty or null');
          return null;
        }
      } else {
        print("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEducationalPlan() async {
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('token')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1/admin/geteducationalplan'));
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          print('jsonResponse: $jsonResponse');
          return jsonResponse;
        } else {
          print('Response body is empty or null');
          return null;
        }
      } else {
        print("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print('error: Failed to make HTTP request: $e');
      return null;
    }
  }
}
