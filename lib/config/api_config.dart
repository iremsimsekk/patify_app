import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  static const int port = 8080;

  // Fiziksel telefonla test edeceksen PC IP'ni yaz (Android/iOS physical device için)
  static const String devMachineIp = "192.168.1.34";

  static String get baseUrl {
    // Web
    if (kIsWeb) return "http://localhost:$port";

    // Android Emulator
    if (Platform.isAndroid) {
      return "http://10.0.2.2:$port";
    }

    // iOS Simulator
    if (Platform.isIOS) {
      return "http://localhost:$port";
    }

    // ✅ Desktop (Windows/macOS/Linux) -> localhost
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return "http://localhost:$port";
    }

    // Physical device (nadiren buraya düşersin; ama kalsın)
    return "http://$devMachineIp:$port";
  }
}
