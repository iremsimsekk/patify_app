import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/stitch_config.dart';
import '../models/stitch_design_dna.dart';

class StitchApiService {
  StitchApiService({
    required StitchConfig config,
    Dio? dio,
  })  : _config = config,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: config.baseUrl,
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 12),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  if (config.apiKey.isNotEmpty)
                    'Authorization': 'Bearer ${config.apiKey}',
                },
              ),
            );

  factory StitchApiService.fromEnv() {
    return StitchApiService(config: StitchConfig.fromEnv());
  }

  final StitchConfig _config;
  final Dio _dio;

  Future<StitchDesignDna?> fetchDesignDna() async {
    if (!_config.isConfigured) {
      debugPrint(
        'StitchApiService: Stitch config is incomplete, using local fallback theme.',
      );
      return null;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.resolvedThemePath,
      );

      final payload = response.data;
      if (payload == null) {
        debugPrint('StitchApiService: Empty Stitch response received.');
        return null;
      }

      final dnaPayload = _extractDesignPayload(payload);
      return StitchDesignDna.fromJson(dnaPayload);
    } on DioException catch (error) {
      debugPrint(
        'StitchApiService: Failed to fetch design DNA (${error.message}).',
      );
      return null;
    } catch (error) {
      debugPrint(
        'StitchApiService: Unexpected design parsing error ($error).',
      );
      return null;
    }
  }

  Map<String, dynamic> _extractDesignPayload(Map<String, dynamic> payload) {
    final nestedCandidates = <dynamic>[
      payload['data'],
      payload['design'],
      payload['tokens'],
      payload['theme'],
    ];

    for (final candidate in nestedCandidates) {
      if (candidate is Map<String, dynamic>) {
        return candidate;
      }
    }

    return payload;
  }
}
