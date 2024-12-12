import 'dart:async';
import 'dart:html' as html;
import 'package:qiot_admin/helpers/session_storage_helpers.dart';
import 'package:qiot_admin/services/api/authentication.dart';
import 'package:qiot_admin/main.dart';

class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  Timer? _timer;
  String? _deviceToken;
  String? _deviceType;

  factory TokenRefreshService() {
    return _instance;
  }

  TokenRefreshService._internal();

  void initialize(String? deviceToken, String deviceType) {
    print('device token : ${deviceToken}');
    print('device type : ${deviceType}');

    _deviceToken = deviceToken;
    _deviceType = deviceType;
    _timer = Timer.periodic(const Duration(minutes: 45), (timer) async {
      startTokenRefreshTimer();
    });
    _setupVisibilityChangeListener();
  }

  void startTokenRefreshTimer() async {
    _timer?.cancel();
    await _refreshToken();
  }

  Future<void> _refreshToken() async {
    if (_deviceType == null) {
      logger.d('Token refresh skipped: insufficient data.');
      return;
    }
    String? accessToken = await SessionStorageHelpers.getStorage('accessToken');
    String? refreshToken =
        await SessionStorageHelpers.getStorage('refreshToken');
  

    try {
      final response = await Authentication().refreshToken(
        accessToken!,
        refreshToken!,
        _deviceToken,
        _deviceType!,
      );
      final jsonResponse = response;
      if (jsonResponse['data']['status'] == 200) {
        final newAccessToken = jsonResponse['data']['accessToken'];
        final newRefreshToken = jsonResponse['data']['refreshToken'];
        _updateTokens(newAccessToken, newRefreshToken);
      }
    } catch (e) {
      logger.d('Failed to refresh : $e');
    }
  }

  void _updateTokens(String newAccessToken, String newRefreshToken) {
    SessionStorageHelpers.setStorage('accessToken', newAccessToken);
    SessionStorageHelpers.setStorage('refreshToken', newRefreshToken);
  }

  void _setupVisibilityChangeListener() {
    html.document.onVisibilityChange.listen((event) {
      if (html.document.visibilityState == 'visible') {
        logger.d('App is visible again');
        startTokenRefreshTimer(); // Restart timer when app becomes visible
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
