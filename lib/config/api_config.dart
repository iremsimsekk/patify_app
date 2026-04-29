import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  static const int port = 8080;
  static const String defaultBaseUrl = 'http://192.168.1.243:8080';

  // Preferred full override, for example:
  // --dart-define=API_BASE_URL=http://192.168.1.243:8080
  static const String apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // Backward-compatible fallback for older local commands.
  static const String legacyBackendBaseUrlOverride =
      String.fromEnvironment('BACKEND_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (apiBaseUrlOverride.isNotEmpty) {
      return apiBaseUrlOverride;
    }

    if (legacyBackendBaseUrlOverride.isNotEmpty) {
      return legacyBackendBaseUrlOverride;
    }

    if (kIsWeb) {
      return defaultBaseUrl;
    }

    if (Platform.isAndroid) {
      return defaultBaseUrl;
    }

    if (Platform.isIOS) {
      return defaultBaseUrl;
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return defaultBaseUrl;
    }

    return defaultBaseUrl;
  }
}
