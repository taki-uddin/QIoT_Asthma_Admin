import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
      // if (response.statusCode == 403) {
      //   print('calling the api again');
      // }

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
      print('the requestes data for user is:');
      print(request);
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('the value is for user data:');
        print(responseBody);
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
      print('the requestes data is:');
      print(request);
      print(headers);
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('the value is for peakflow is data:');
        print(responseBody);
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

  static Future<Map<String, dynamic>?> getInhalerhistories(
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
            '${ApiConstants.baseURL}/admin/inhalerhistories?userId=$userId&month=$month&year=$year'));
    request.headers.addAll(headers);

    try {
      print('the requestes data is:');
      print(request);
      print(headers);
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('the value is for inhaler is data:');
        print(responseBody);
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

  static Future<Map<String, dynamic>?> getPeakflowhistoryReport(
      BuildContext context,
      String userId,
      int startmonth,
      int startyear,
      int endmonth,
      int endyear) async {
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
      } else if (response.statusCode == 404) {
        print('no data found');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Data Found'),
              content:
                  const Text('No data is available for the selected period.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getInhalerhistoryReport(
      BuildContext context,
      String userId,
      int startmonth,
      int startyear,
      int endmonth,
      int endyear) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/inhalerhistoryreport?userId=$userId&startmonth=$startmonth&startyear=$startyear&endmonth=$endmonth&endyear=$endyear'));
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
      } else if (response.statusCode == 404) {
        print('no data found');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Data Found'),
              content:
                  const Text('No data is available for the selected period.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('eror not found the value');
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

  static Future<Map<String, dynamic>?> getAsthmahistoryReport(
      BuildContext context,
      String userId,
      int startmonth,
      int startyear,
      int endmonth,
      int endyear) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/acthistoriesreport?userId=$userId&startmonth=$startmonth&startyear=$startyear&endmonth=$endmonth&endyear=$endyear'));
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
      } else if (response.statusCode == 404) {
        print('no data found');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Data Found'),
              content:
                  const Text('No data is available for the selected period.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('eror not found the value');
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getSteroidhistoryReport(
      BuildContext context,
      String userId,
      int startmonth,
      int startyear,
      int endmonth,
      int endyear) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/steroiddosehistoryreport?userId=$userId&startmonth=$startmonth&startyear=$startyear&endmonth=$endmonth&endyear=$endyear'));
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
      } else if (response.statusCode == 404) {
        print('no data found');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Data Found'),
              content:
                  const Text('No data is available for the selected period.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('eror not found the value');
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getSteroidhistories(
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
            '${ApiConstants.baseURL}/admin/steroiddose?userId=$userId&month=$month&year=$year'));
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

  static Future<Map<String, dynamic>?> getdiurinalhistories(
      String userId, int month, int year, String type) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/diurinalhistories?id=$userId&type=$type&month=$month&year=$year'));
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

  static Future<Map<String, dynamic>?> getDiurinalhistoryReport(
      BuildContext context,
      String userId,
      int startmonth,
      int startyear,
      String type,
      int endmonth,
      int endyear) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/diurinalhistoryreport?id=$userId&type=$type&startmonth=$startmonth&startyear=$startyear&endmonth=$endmonth&endyear=$endyear'));
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
      } else if (response.statusCode == 404) {
        print('no data found');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Data Found'),
              content:
                  const Text('No data is available for the selected period.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('eror not found the value');
        logger.d("error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      logger.d('error: Failed to make HTTP request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getFitnessStresshistories(
      String userId, int month, int year) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    print('entered at api calling');

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/fitnessAndStresshistories?userId=$userId&month=$month&year=$year'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      logger.d(responseBody);

      print('entered status code');
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

  static Future<Map<String, dynamic>?> getFitnessStresshistoryReport(
      BuildContext context,
      String userId,
      int startmonth,
      int startyear,
      int endmonth,
      int endyear) async {
    logger.d('userId: ${userId}');
    var headers = {
      // 'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseURL}/admin/fitnessAndStresshistoryreport?userId=$userId&startmonth=$startmonth&startyear=$startyear&endmonth=$endmonth&endyear=$endyear'));
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
      } else if (response.statusCode == 404) {
        print('no data found');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Data Found'),
              content:
                  const Text('No data is available for the selected period.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('eror not found the value');
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

  String _getContentType(String filename) {
    String extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  Future<Map<String, dynamic>?> uploadEducationalPlan(
    html.File file,
  ) async {
    var headers = {
      'Authorization':
          'Bearer ${await SessionStorageHelpers.getStorage('accessToken')}',
    };

    var request = http.MultipartRequest('POST',
        Uri.parse('${ApiConstants.baseURL}/admin/uploadeducationalplan'));

    try {
      // Read file bytes using FileReader
      var reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first; // Wait for file to be loaded

      // Convert to Uint8List for proper binary handling
      Uint8List fileBytes = Uint8List.fromList(reader.result as List<int>);

      logger.d('File name: ${file.name}');
      logger.d('File size: ${fileBytes.length} bytes');
      logger.d('File type: ${file.type}');

      // Validate file is not empty
      if (fileBytes.isEmpty) {
        logger.d('Error: File is empty');
        return {'error': 'File is empty'};
      }

      // Log file information for debugging
      logger.d('File size: ${fileBytes.length} bytes');
      if (fileBytes.length >= 4) {
        String header = String.fromCharCodes(fileBytes.take(4));
        logger.d('File header: $header');
      }

      // Determine content type based on file extension
      String contentType = _getContentType(file.name);

      // Add the file to the request with proper content type
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // The name of the field expected by the server
          fileBytes, // The file bytes
          filename: file.name, // The file name
          contentType: MediaType.parse(contentType),
        ),
      );

      // Add headers to the request
      request.headers.addAll(headers);

      logger.d('Sending request to: ${request.url}');
      logger.d('Request headers: ${request.headers}');

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: $responseBody');

      if (response.statusCode == 200) {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          logger.d('Upload successful: $jsonResponse');
          return jsonResponse;
        } else {
          logger.d('Response body is empty or null');
          return {'error': 'Empty response from server'};
        }
      } else {
        logger.d(
            "Upload failed with status ${response.statusCode}: ${response.reasonPhrase}");
        logger.d("Error response: $responseBody");
        return {'error': 'Upload failed: ${response.reasonPhrase}'};
      }
    } catch (e) {
      logger.d('Exception during upload: $e');
      return {'error': 'Upload failed: $e'};
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
