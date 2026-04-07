import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  static const int port = 8080;

  // Local network IP of the machine running the backend.
  static const String devMachineIp = '192.168.1.34';

  // Optional full override, for example:
  // --dart-define=BACKEND_BASE_URL=http://192.168.1.34:8080
  static const String backendBaseUrlOverride =
      String.fromEnvironment('BACKEND_BASE_URL', defaultValue: '');

  // Enable this when running on physical Android/iOS devices without changing code:
  // --dart-define=USE_DEVICE_IP_FOR_MOBILE=true
  static const bool useDeviceIpForMobile =
      bool.fromEnvironment('USE_DEVICE_IP_FOR_MOBILE', defaultValue: false);

  static String get baseUrl {
    if (backendBaseUrlOverride.isNotEmpty) {
      return backendBaseUrlOverride;
    }

    if (kIsWeb) {
      return 'http://localhost:$port';
    }

    if (Platform.isAndroid) {
      return useDeviceIpForMobile
          ? 'http://$devMachineIp:$port'
          : 'http://10.0.2.2:$port';
    }

    if (Platform.isIOS) {
      return useDeviceIpForMobile
          ? 'http://$devMachineIp:$port'
          : 'http://localhost:$port';
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:$port';
    }

    return 'http://$devMachineIp:$port';
  }
}
