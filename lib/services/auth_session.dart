import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:qiot_admin/helpers/session_storage_helpers.dart';
import 'package:qiot_admin/services/api/authentication.dart';

/// Global navigator for auth redirects outside widget tree.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final Logger _authLogger = Logger();

class AuthSession {
  AuthSession._();

  static const _expirySkewSeconds = 60;

  static bool isUnauthorizedStatus(int statusCode) =>
      statusCode == 401 || statusCode == 403;

  /// Decode JWT payload and return exp claim (seconds since epoch), or null.
  static int? accessTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          json.decode(utf8.decode(base64Url.decode(normalized))) as Map;
      final exp = payload['exp'];
      if (exp is int) return exp;
      if (exp is num) return exp.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  static bool isAccessTokenExpired(String accessToken) {
    final exp = accessTokenExpiry(accessToken);
    if (exp == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp <= now + _expirySkewSeconds;
  }

  static Future<bool> hasStoredCredentials() async {
    final access = await SessionStorageHelpers.getStorage('accessToken');
    final refresh = await SessionStorageHelpers.getStorage('refreshToken');
    return access != null &&
        access.isNotEmpty &&
        refresh != null &&
        refresh.isNotEmpty;
  }

  static Future<bool> tryRefreshToken() async {
    final refreshToken =
        await SessionStorageHelpers.getStorage('refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await Authentication.refreshToken(
        refreshToken: refreshToken,
        deviceToken: null,
        deviceType: 'web',
      );
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data != null && data['status'] == 200) {
          final newAccess = data['accessToken']?.toString();
          final newRefresh = data['refreshToken']?.toString();
          if (newAccess != null && newRefresh != null) {
            await SessionStorageHelpers.setStorage('accessToken', newAccess);
            await SessionStorageHelpers.setStorage('refreshToken', newRefresh);
            await SessionStorageHelpers.setStorage('loginState', 'true');
            return true;
          }
        }
      }
    } catch (e) {
      _authLogger.d('Token refresh failed: $e');
    }
    return false;
  }

  /// Returns true when the caller may proceed with authenticated API calls.
  static Future<bool> ensureValidSession() async {
    if (!await hasStoredCredentials()) {
      return false;
    }

    final access = await SessionStorageHelpers.getStorage('accessToken');
    if (access == null || access.isEmpty) {
      return false;
    }

    if (!isAccessTokenExpired(access)) {
      await SessionStorageHelpers.setStorage('loginState', 'true');
      return true;
    }

    return tryRefreshToken();
  }

  static Future<void> clearSession() async {
    await SessionStorageHelpers.clearStorage();
  }

  static Future<void> redirectToLogin({String? message}) async {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil('/', (route) => false);

    if (message != null && message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      });
    }
  }

  static Future<void> handleUnauthorized({String? message}) async {
    await clearSession();
    await redirectToLogin(
      message: message ?? 'Session expired. Please sign in again.',
    );
  }

  static Future<void> rejectIfUnauthorized(int statusCode) async {
    if (isUnauthorizedStatus(statusCode)) {
      await handleUnauthorized();
    }
  }
}
