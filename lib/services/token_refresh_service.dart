import 'dart:async';
import 'dart:html' as html;
import 'package:qiot_admin/helpers/session_storage_helpers.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/services/auth_session.dart';

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
    _deviceToken = deviceToken;
    _deviceType = deviceType;
    _timer = Timer.periodic(const Duration(minutes: 45), (_) {
      startTokenRefreshTimer();
    });
    _setupVisibilityChangeListener();
    _setupCrossTabLogoutListener();
  }

  void startTokenRefreshTimer() async {
    await _refreshTokenIfNeeded();
  }

  Future<void> _refreshTokenIfNeeded() async {
    if (_deviceType == null) return;
    if (!await AuthSession.hasStoredCredentials()) return;

    final accessToken = await SessionStorageHelpers.getStorage('accessToken');
    if (accessToken != null && !AuthSession.isAccessTokenExpired(accessToken)) {
      return;
    }

    final refreshed = await AuthSession.tryRefreshToken();
    if (!refreshed) {
      await AuthSession.handleUnauthorized();
    }
  }

  void _setupVisibilityChangeListener() {
    html.document.onVisibilityChange.listen((_) {
      if (html.document.visibilityState == 'visible') {
        logger.d('App visible — validating session');
        startTokenRefreshTimer();
      }
    });
  }

  void _setupCrossTabLogoutListener() {
    html.window.onStorage.listen((event) {
      if (event.key == 'loginState' && (event.newValue == null || event.newValue!.isEmpty)) {
        AuthSession.redirectToLogin();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
