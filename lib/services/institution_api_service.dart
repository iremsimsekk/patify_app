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
      final id = _readString(data, ['id']) ?? institutionId;

      return PlaceDetails(
        placeId: id,
        name: _readString(data, ['name']) ?? '',
        formattedAddress: _readString(data, ['address']),
        phone: _readString(data, ['phone']),
        internationalPhoneNumber: _readString(
          data,
          ['internationalPhoneNumber', 'international_phone_number'],
        ),
        website: _readString(data, ['website']),
        rating: _readDouble(data, ['rating']),
        userRatingsTotal: _readInt(
          data,
          ['userRatingCount', 'user_rating_count', 'userRatingsTotal'],
        ),
        weekdayText: _readStringList(data, ['openingHours', 'opening_hours']),
        googleMapsUrl: _readString(data, ['googleMapsUrl', 'google_maps_url']),
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
        final lat = _readDouble(row, ['latitude']);
        final lng = _readDouble(row, ['longitude']);

        return PlaceSummary(
          placeId: id,
          name: _readString(row, ['name']) ?? '',
          lat: (lat ?? 0).toDouble(),
          lng: (lng ?? 0).toDouble(),
          address: _readString(row, ['address']),
          phone: _readString(row, ['phone']),
          internationalPhoneNumber: _readString(
            row,
            ['internationalPhoneNumber', 'international_phone_number'],
          ),
          website: _readString(row, ['website']),
          rating: _readDouble(row, ['rating']),
          userRatingsTotal: _readInt(
            row,
            ['userRatingCount', 'user_rating_count', 'userRatingsTotal'],
          ),
          openingHours: _readStringList(row, ['openingHours', 'opening_hours']),
          googleMapsUrl: _readString(row, ['googleMapsUrl', 'google_maps_url']),
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

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String && value.trim().isNotEmpty) {
        return double.tryParse(value);
      }
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String && value.trim().isNotEmpty) {
        return int.tryParse(value);
      }
    }
    return null;
  }

  static List<String>? _readStringList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) {
        final list = value
            .map((entry) => entry?.toString().trim())
            .whereType<String>()
            .where((entry) => entry.isNotEmpty)
            .toList(growable: false);
        if (list.isNotEmpty) {
          return list;
        }
      }
      if (value is String && value.trim().isNotEmpty) {
        return [value.trim()];
      }
    }
    return null;
  }
}
