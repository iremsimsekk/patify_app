import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

enum PlaceCategory { vet, shelter }

class PlaceSummary {
  final String placeId;
  final String name;
  final double lat;
  final double lng;
  final String? address;
  final double? rating;
  final int? userRatingsTotal;
  final String? photoReference;
  final PlaceCategory category;

  PlaceSummary({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.category,
    this.address,
    this.rating,
    this.userRatingsTotal,
    this.photoReference,
  });

  factory PlaceSummary.fromPlacesJson(
    Map<String, dynamic> json, {
    required PlaceCategory category,
  }) {
    final loc = (json['geometry']?['location'] ?? {}) as Map<String, dynamic>;
    final photos = (json['photos'] as List?)?.cast<Map<String, dynamic>>();

    return PlaceSummary(
      placeId: (json['place_id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      lat: (loc['lat'] as num).toDouble(),
      lng: (loc['lng'] as num).toDouble(),
      address: (json['formatted_address'] ?? json['vicinity']) as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
      photoReference: photos?.isNotEmpty == true
          ? photos!.first['photo_reference'] as String?
          : null,
      category: category,
    );
  }

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'name': name,
        'lat': lat,
        'lng': lng,
        'address': address,
        'rating': rating,
        'userRatingsTotal': userRatingsTotal,
        'photoReference': photoReference,
        'category': category.name,
      };

  factory PlaceSummary.fromJson(Map<String, dynamic> json) {
    final catStr = (json['category'] ?? 'vet') as String;
    final cat = PlaceCategory.values.firstWhere(
      (entry) => entry.name == catStr,
      orElse: () => PlaceCategory.vet,
    );

    return PlaceSummary(
      placeId: (json['placeId'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      lat: ((json['lat'] ?? 0) as num).toDouble(),
      lng: ((json['lng'] ?? 0) as num).toDouble(),
      address: json['address'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['userRatingsTotal'] as int?,
      photoReference: json['photoReference'] as String?,
      category: cat,
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String? formattedAddress;
  final String? phone;
  final String? website;
  final double? rating;
  final int? userRatingsTotal;
  final List<String>? weekdayText;
  final String? googleMapsUrl;

  PlaceDetails({
    required this.placeId,
    required this.name,
    this.formattedAddress,
    this.phone,
    this.website,
    this.rating,
    this.userRatingsTotal,
    this.weekdayText,
    this.googleMapsUrl,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final result = (json['result'] ?? {}) as Map<String, dynamic>;
    final opening = result['opening_hours'] as Map<String, dynamic>?;
    final weekday = (opening?['weekday_text'] as List?)?.cast<String>();

    return PlaceDetails(
      placeId: (result['place_id'] ?? '') as String,
      name: (result['name'] ?? '') as String,
      formattedAddress: result['formatted_address'] as String?,
      phone: result['formatted_phone_number'] as String?,
      website: result['website'] as String?,
      rating: (result['rating'] as num?)?.toDouble(),
      userRatingsTotal: result['user_ratings_total'] as int?,
      weekdayText: weekday,
      googleMapsUrl: result['url'] as String?,
    );
  }
}

class GooglePlacesService {
  GooglePlacesService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  static const _nearbyUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const _textUrl =
      'https://maps.googleapis.com/maps/api/place/textsearch/json';
  static const _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  static const ankaraLat = 39.92077;
  static const ankaraLng = 32.85411;

  Future<List<PlaceSummary>> fetchAnkaraVets({int radiusMeters = 35000}) async {
    final tr = await _pagedTextSearch(
      query: 'veteriner ankara',
      lat: ankaraLat,
      lng: ankaraLng,
      radiusMeters: radiusMeters,
      category: PlaceCategory.vet,
    );
    final en = await _pagedTextSearch(
      query: 'veterinary clinic ankara',
      lat: ankaraLat,
      lng: ankaraLng,
      radiusMeters: radiusMeters,
      category: PlaceCategory.vet,
    );

    final map = <String, PlaceSummary>{};
    for (final place in [...tr, ...en]) {
      if (place.placeId.isNotEmpty) {
        map[place.placeId] = place;
      }
    }
    return map.values.toList();
  }

  Future<List<PlaceSummary>> fetchAnkaraShelters({
    int radiusMeters = 35000,
  }) async {
    final tr = await _pagedTextSearch(
      query: 'hayvan barınağı ankara',
      lat: ankaraLat,
      lng: ankaraLng,
      radiusMeters: radiusMeters,
      category: PlaceCategory.shelter,
    );
    final en = await _pagedTextSearch(
      query: 'animal shelter ankara',
      lat: ankaraLat,
      lng: ankaraLng,
      radiusMeters: radiusMeters,
      category: PlaceCategory.shelter,
    );

    final map = <String, PlaceSummary>{};
    for (final place in [...tr, ...en]) {
      if (place.placeId.isNotEmpty) {
        map[place.placeId] = place;
      }
    }
    return map.values.toList();
  }

  Future<PlaceDetails> fetchDetails(String placeId) async {
    final uri = Uri.parse(_detailsUrl).replace(
      queryParameters: {
        'place_id': placeId,
        'fields': [
          'place_id',
          'name',
          'formatted_address',
          'formatted_phone_number',
          'website',
          'rating',
          'user_ratings_total',
          'opening_hours',
          'url',
        ].join(','),
        'key': apiKey,
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Place Details HTTP ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final status = json['status'] as String?;
    if (status != 'OK') {
      throw Exception('Place Details status=$status, body=${response.body}');
    }
    return PlaceDetails.fromJson(json);
  }

  Future<List<PlaceSummary>> _pagedNearbySearch({
    required double lat,
    required double lng,
    required int radiusMeters,
    required String type,
    required PlaceCategory category,
  }) async {
    final out = <PlaceSummary>[];
    String? nextToken;

    for (int page = 0; page < 3; page++) {
      if (nextToken != null) {
        await Future.delayed(const Duration(seconds: 2));
      }

      final uri = Uri.parse(_nearbyUrl).replace(
        queryParameters: {
          if (nextToken != null) 'pagetoken': nextToken,
          if (nextToken == null) 'location': '$lat,$lng',
          if (nextToken == null) 'radius': '$radiusMeters',
          if (nextToken == null) 'type': type,
          'language': 'tr',
          'key': apiKey,
        },
      );

      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Nearby HTTP ${response.statusCode}: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        throw Exception('Nearby status=$status body=${response.body}');
      }

      final results = (json['results'] as List? ?? []).cast<Map<String, dynamic>>();
      out.addAll(
        results.map(
          (entry) => PlaceSummary.fromPlacesJson(entry, category: category),
        ),
      );

      nextToken = json['next_page_token'] as String?;
      if (nextToken == null) break;
    }

    return out.where((entry) => entry.placeId.isNotEmpty).toList();
  }

  Future<List<PlaceSummary>> _pagedTextSearch({
    required String query,
    required double lat,
    required double lng,
    required int radiusMeters,
    required PlaceCategory category,
  }) async {
    final out = <PlaceSummary>[];
    String? nextToken;

    for (int page = 0; page < 3; page++) {
      if (nextToken != null) {
        await Future.delayed(const Duration(seconds: 2));
      }

      final uri = Uri.parse(_textUrl).replace(
        queryParameters: {
          if (nextToken != null) 'pagetoken': nextToken,
          if (nextToken == null) 'query': query,
          if (nextToken == null) 'location': '$lat,$lng',
          if (nextToken == null) 'radius': '$radiusMeters',
          'language': 'tr',
          'region': 'tr',
          'key': apiKey,
        },
      );

      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('TextSearch HTTP ${response.statusCode}: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        throw Exception('TextSearch status=$status body=${response.body}');
      }

      final results = (json['results'] as List? ?? []).cast<Map<String, dynamic>>();
      out.addAll(
        results.map(
          (entry) => PlaceSummary.fromPlacesJson(entry, category: category),
        ),
      );

      nextToken = json['next_page_token'] as String?;
      if (nextToken == null) break;
    }

    return out.where((entry) => entry.placeId.isNotEmpty).toList();
  }
}
