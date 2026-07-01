import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';

class AsthmaActionPlanUpload {
  AsthmaActionPlanUpload._();

  static const int maxSizeInBytes = 5 * 1024 * 1024;
  static const allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  static bool hasPlan(dynamic user) {
    final url = user is Map ? user['asthmaActionPlan']?.toString().trim() : '';
    return url != null && url.isNotEmpty;
  }

  static String? planUrl(dynamic user) {
    if (user is! Map) return null;
    final url = user['asthmaActionPlan']?.toString().trim() ?? '';
    return url.isEmpty ? null : url;
  }

  static void openPlan(String url) {
    html.window.open(url, '_blank');
  }

  /// Picks a file, validates size, uploads, and returns the new URL on success.
  static Future<String?> pickAndUpload(String userId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    if (file.bytes == null) {
      throw AsthmaActionPlanUploadException('Could not read the selected file');
    }

    if (file.size > maxSizeInBytes) {
      throw AsthmaActionPlanUploadException(
        'File size exceeds the 5MB limit',
      );
    }

    final webFile = html.File(file.bytes!, file.name);
    final response =
        await DashboardUsersData().uploadUsersAsthmaActionPlan(webFile, userId);

    if (response == null) {
      throw AsthmaActionPlanUploadException(
        'Failed to upload asthma action plan',
      );
    }

    if (response['status'] != 200) {
      throw AsthmaActionPlanUploadException(
        response['message']?.toString() ??
            'Failed to upload asthma action plan',
      );
    }

    return response['url']?.toString();
  }
}

class AsthmaActionPlanUploadException implements Exception {
  final String message;
  AsthmaActionPlanUploadException(this.message);

  @override
  String toString() => message;
}
