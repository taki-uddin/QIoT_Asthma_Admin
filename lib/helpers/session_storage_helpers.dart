import 'package:universal_html/html.dart';

class SessionStorageHelpers {
  static Storage sessionStorage = window.sessionStorage;

  static Future<void> setStorage(String key, String value) async {
    sessionStorage[key] = value;
  }

  static Future<String?> getStorage(String key) async {
    return sessionStorage[key];
  }

  static Future<void> removeStorage(String key) async {
    sessionStorage.remove(key);
  }

  static Future<void> clearStorage() async {
    sessionStorage.clear();
  }
}
