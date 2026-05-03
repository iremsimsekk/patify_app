import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static String get stitchApiKey => dotenv.env['STITCH_API_KEY']?.trim() ?? '';
  static String get stitchApiBaseUrl =>
      dotenv.env['STITCH_API_BASE_URL']?.trim() ?? '';
  static String get stitchProjectId =>
      dotenv.env['STITCH_PROJECT_ID']?.trim() ?? '';
  static String get stitchDesignId =>
      dotenv.env['STITCH_DESIGN_ID']?.trim() ?? '';
  static String get stitchThemeEndpoint =>
      dotenv.env['STITCH_THEME_ENDPOINT']?.trim() ?? '';
}
