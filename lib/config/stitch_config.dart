import 'app_env.dart';

class StitchConfig {
  const StitchConfig({
    required this.apiKey,
    required this.baseUrl,
    required this.projectId,
    required this.designId,
    required this.themeEndpointTemplate,
  });

  final String apiKey;
  final String baseUrl;
  final String projectId;
  final String designId;
  final String themeEndpointTemplate;

  factory StitchConfig.fromEnv() {
    return StitchConfig(
      apiKey: AppEnv.stitchApiKey,
      baseUrl: AppEnv.stitchApiBaseUrl,
      projectId: AppEnv.stitchProjectId,
      designId: AppEnv.stitchDesignId,
      themeEndpointTemplate: AppEnv.stitchThemeEndpoint,
    );
  }

  bool get isConfigured =>
      apiKey.isNotEmpty &&
      baseUrl.isNotEmpty &&
      projectId.isNotEmpty &&
      designId.isNotEmpty &&
      themeEndpointTemplate.isNotEmpty;

  String get resolvedThemePath => themeEndpointTemplate
      .replaceAll('{projectId}', projectId)
      .replaceAll('{designId}', designId);
}
