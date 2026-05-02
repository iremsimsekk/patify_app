import 'package:dio/dio.dart';

import 'api_client.dart';
import 'app_preferences.dart';

class VeterinarianClaimStatusResponse {
  const VeterinarianClaimStatusResponse({
    required this.status,
    required this.institution,
  });

  final String status;
  final VeterinarianInstitutionSummary? institution;

  bool get isApproved => status == 'APPROVED';

  factory VeterinarianClaimStatusResponse.fromJson(Map<String, dynamic> json) {
    return VeterinarianClaimStatusResponse(
      status: (json['status'] ?? 'NONE').toString(),
      institution: json['institution'] is Map<String, dynamic>
          ? VeterinarianInstitutionSummary.fromJson(
              json['institution'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class VeterinarianInstitutionSummary {
  const VeterinarianInstitutionSummary({
    required this.id,
    required this.name,
    required this.address,
    required this.email,
    required this.city,
    required this.district,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final String? address;
  final String? email;
  final String? city;
  final String? district;
  final double? latitude;
  final double? longitude;

  factory VeterinarianInstitutionSummary.fromJson(Map<String, dynamic> json) {
    return VeterinarianInstitutionSummary(
      id: _readInt(json['id']),
      name: (json['name'] ?? '').toString(),
      address: _readNullableString(json['address']),
      email: _readNullableString(json['email']),
      city: _readNullableString(json['city']),
      district: _readNullableString(json['district']),
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
    );
  }
}

class VeterinarianInstitutionSearchItem {
  const VeterinarianInstitutionSearchItem({
    required this.id,
    required this.name,
    required this.address,
    required this.email,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final String? address;
  final String? email;
  final double? latitude;
  final double? longitude;

  factory VeterinarianInstitutionSearchItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return VeterinarianInstitutionSearchItem(
      id: _readInt(json['id']),
      name: (json['name'] ?? '').toString(),
      address: _readNullableString(json['address']),
      email: _readNullableString(json['email']),
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
    );
  }
}

class VeterinarianClaimService {
  VeterinarianClaimService._();

  static Future<VeterinarianClaimStatusResponse> fetchClaimStatus() async {
    try {
      final res = await ApiClient.dio.get(
        '/api/veterinarian/claim-status',
        options: await _authorizedOptions(),
      );
      return VeterinarianClaimStatusResponse.fromJson(
        res.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<List<VeterinarianInstitutionSearchItem>> searchInstitutions({
    String query = '',
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/api/veterinarian/institutions/search',
        queryParameters: {'query': query},
        options: await _authorizedOptions(),
      );

      final rows = (res.data as List).cast<Map<String, dynamic>>();
      return rows
          .map(VeterinarianInstitutionSearchItem.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<VeterinarianClaimStatusResponse> submitClaimRequest({
    required int institutionId,
    String? requestNote,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        '/api/veterinarian/claim-requests',
        data: {
          'institutionId': institutionId,
          if (requestNote != null && requestNote.trim().isNotEmpty)
            'requestNote': requestNote.trim(),
        },
        options: await _authorizedOptions(),
      );

      return VeterinarianClaimStatusResponse.fromJson(
        res.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<Options> _authorizedOptions() async {
    final token = await AppPreferences.loadAuthToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception('AUTH_TOKEN_MISSING');
    }
    return Options(
      headers: {
        'Authorization': 'Bearer ${token.trim()}',
      },
    );
  }

  static String _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return error.message ?? error.toString();
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String && value.trim().isNotEmpty) {
    return double.tryParse(value);
  }
  return null;
}

String? _readNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
