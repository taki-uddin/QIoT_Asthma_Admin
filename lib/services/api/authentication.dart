import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qiot_admin/helpers/session_storage_helpers.dart';

class Authentication {
  static Future<Map<String, dynamic>> signIn(String email, String password,
      String? deviceToken, String? deviceType) async {
    var headers = {
      'Content-Type': 'application/json',
    };

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1/auth/signin'));
    request.body = json.encode({
      "email": email,
      "password": password,
      "deviceType": deviceType,
    });
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic> jsonResponse = json.decode(responseBody);
          return {'success': true, 'data': jsonResponse};
        } else {
          return {'success': false, 'error': 'Response body is empty or null'};
        }
      } else {
        return {'success': false, 'error': response.reasonPhrase};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to make HTTP request: $e'};
    }
  }

  static Future<Map<String, dynamic>> signOut() async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };
    print(await SessionStorageHelpers.getStorage('userID'));

    var request = http.Request(
        'DELETE',
        Uri.parse(
            'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1/auth/signout/${await SessionStorageHelpers.getStorage('userID')}'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          SessionStorageHelpers.clearStorage();
          return {'success': true, 'data': jsonResponse};
        } else {
          return {'success': false, 'error': 'Response body is empty or null'};
        }
      } else {
        return {'success': false, 'error': response.reasonPhrase};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to make HTTP request: $e'};
    }
  }
}
