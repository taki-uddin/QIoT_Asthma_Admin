import 'package:universal_html/html.dart';

/// Persists auth tokens in localStorage so sessions work across browser tabs.
class SessionStorageHelpers {
  static Storage get _storage => window.localStorage;

  static const _authKeys = [
    'loginState',
    'accessToken',
    'refreshToken',
    'userID',
  ];

  static bool _migratedFromSession = false;

  /// One-time copy from sessionStorage for users who logged in before this change.
  static void _migrateFromSessionStorageIfNeeded() {
    if (_migratedFromSession) return;
    _migratedFromSession = true;

    final session = window.sessionStorage;
    for (final key in _authKeys) {
      final sessionValue = session[key];
      if (sessionValue != null &&
          sessionValue.isNotEmpty &&
          (_storage[key] == null || _storage[key]!.isEmpty)) {
        _storage[key] = sessionValue;
      }
    }
  }

  static Future<void> setStorage(String key, String value) async {
    _migrateFromSessionStorageIfNeeded();
    _storage[key] = value;
    // Keep sessionStorage in sync during transition for any legacy reads.
    window.sessionStorage[key] = value;
  }

  static Future<String?> getStorage(String key) async {
    _migrateFromSessionStorageIfNeeded();
    final value = _storage[key];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return window.sessionStorage[key];
  }

  static Future<void> removeStorage(String key) async {
    _storage.remove(key);
    window.sessionStorage.remove(key);
  }

  static Future<void> clearStorage() async {
    for (final key in _authKeys) {
      _storage.remove(key);
      window.sessionStorage.remove(key);
    }
  }
}
