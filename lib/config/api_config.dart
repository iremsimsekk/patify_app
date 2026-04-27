import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  static const int port = 8080;

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
      return 'http://localhost:$port';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port';
    }

    if (Platform.isIOS) {
      return 'http://localhost:$port';
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:$port';
    }

    return 'http://localhost:$port';
  }
}
