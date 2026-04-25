import 'package:dio/dio.dart';

import 'api_client.dart';
import 'google_places_service.dart';

class InstitutionApiService {
  InstitutionApiService._();

  static Future<List<PlaceSummary>> fetchClinics() async {
    return _fetchList(type: 'clinic', category: PlaceCategory.vet);
  }

  static Future<List<PlaceSummary>> fetchShelters() async {
    return _fetchList(type: 'shelter', category: PlaceCategory.shelter);
  }

  static Future<PlaceDetails> fetchInstitutionDetails(
    String institutionId,
  ) async {
    try {
      final res = await ApiClient.dio.get('/institutions/$institutionId');
      final data = res.data as Map<String, dynamic>;
      final id = (data['id'] ?? institutionId).toString();

      return PlaceDetails(
        placeId: id,
        name: (data['name'] ?? '') as String,
        formattedAddress: data['address'] as String?,
        phone: data['phone'] as String?,
        website: null,
        rating: null,
        userRatingsTotal: null,
        weekdayText: null,
        googleMapsUrl: null,
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<List<PlaceSummary>> _fetchList({
    required String type,
    required PlaceCategory category,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/institutions',
        queryParameters: {'type': type},
      );

      final rows = (res.data as List).cast<Map<String, dynamic>>();
      return rows.map((row) {
        final id = (row['id'] ?? '').toString();
        final lat = row['latitude'] as num?;
        final lng = row['longitude'] as num?;

        return PlaceSummary(
          placeId: id,
          name: (row['name'] ?? '') as String,
          lat: (lat ?? 0).toDouble(),
          lng: (lng ?? 0).toDouble(),
          address: row['address'] as String?,
          rating: null,
          userRatingsTotal: null,
          photoReference: null,
          category: category,
        );
      }).toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
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
