import 'dart:convert';
import 'dart:async';
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
    Map<String, dynamic> j, {
    required PlaceCategory category,
  }) {
    final loc = (j['geometry']?['location'] ?? {}) as Map<String, dynamic>;
    final photos = (j['photos'] as List?)?.cast<Map<String, dynamic>>();

    return PlaceSummary(
      placeId: (j['place_id'] ?? '') as String,
      name: (j['name'] ?? '') as String,
      lat: (loc['lat'] as num).toDouble(),
      lng: (loc['lng'] as num).toDouble(),
      // textsearch -> formatted_address, nearby -> vicinity
      address: (j['formatted_address'] ?? j['vicinity']) as String?,
      rating: (j['rating'] as num?)?.toDouble(),
      userRatingsTotal: j['user_ratings_total'] as int?,
      photoReference: photos?.isNotEmpty == true
          ? photos!.first['photo_reference'] as String?
          : null,
      category: category,
    );
  }

  // ✅ Cache için
  Map<String, dynamic> toJson() => {
        "placeId": placeId,
        "name": name,
        "lat": lat,
        "lng": lng,
        "address": address,
        "rating": rating,
        "userRatingsTotal": userRatingsTotal,
        "photoReference": photoReference,
        "category": category.name,
      };

  // ✅ Cache için
  factory PlaceSummary.fromJson(Map<String, dynamic> j) {
    final catStr = (j["category"] ?? "vet") as String;
    final cat = PlaceCategory.values.firstWhere(
      (e) => e.name == catStr,
      orElse: () => PlaceCategory.vet,
    );

    return PlaceSummary(
      placeId: (j["placeId"] ?? "") as String,
      name: (j["name"] ?? "") as String,
      lat: ((j["lat"] ?? 0) as num).toDouble(),
      lng: ((j["lng"] ?? 0) as num).toDouble(),
      address: j["address"] as String?,
      rating: (j["rating"] as num?)?.toDouble(),
      userRatingsTotal: j["userRatingsTotal"] as int?,
      photoReference: j["photoReference"] as String?,
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

  factory PlaceDetails.fromJson(Map<String, dynamic> j) {
    final result = (j['result'] ?? {}) as Map<String, dynamic>;
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

  // Ankara merkez
  static const ankaraLat = 39.92077;
  static const ankaraLng = 32.85411;

  /// ✅ Veterinerleri artık Text Search ile çekiyoruz ki formatted_address dolu gelsin
  /// ve ilçe filtresi düzgün çalışsın.
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
    for (final p in [...tr, ...en]) {
      if (p.placeId.isNotEmpty) map[p.placeId] = p;
    }
    return map.values.toList();
  }

  /// Ankara barınakları: text search
  Future<List<PlaceSummary>> fetchAnkaraShelters(
      {int radiusMeters = 35000}) async {
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
    for (final p in [...tr, ...en]) {
      if (p.placeId.isNotEmpty) map[p.placeId] = p;
    }
    return map.values.toList();
  }

  Future<PlaceDetails> fetchDetails(String placeId) async {
    final uri = Uri.parse(_detailsUrl).replace(queryParameters: {
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
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Place Details HTTP ${res.statusCode}: ${res.body}');
    }

    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final status = j['status'] as String?;
    if (status != 'OK') {
      throw Exception('Place Details status=$status, body=${res.body}');
    }
    return PlaceDetails.fromJson(j);
  }

  // (İstersen ileride tekrar nearby kullanırsın diye bıraktım)
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

      final uri = Uri.parse(_nearbyUrl).replace(queryParameters: {
        if (nextToken != null) 'pagetoken': nextToken,
        if (nextToken == null) 'location': '$lat,$lng',
        if (nextToken == null) 'radius': '$radiusMeters',
        if (nextToken == null) 'type': type,
        'language': 'tr',
        'key': apiKey,
      });

      final res = await _client.get(uri);
      if (res.statusCode != 200) {
        throw Exception('Nearby HTTP ${res.statusCode}: ${res.body}');
      }

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final status = j['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        throw Exception('Nearby status=$status body=${res.body}');
      }

      final results =
          (j['results'] as List? ?? []).cast<Map<String, dynamic>>();
      out.addAll(results.map(
          (e) => PlaceSummary.fromPlacesJson(e, category: category)));

      nextToken = j['next_page_token'] as String?;
      if (nextToken == null) break;
    }

    return out.where((e) => e.placeId.isNotEmpty).toList();
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

      final uri = Uri.parse(_textUrl).replace(queryParameters: {
        if (nextToken != null) 'pagetoken': nextToken,
        if (nextToken == null) 'query': query,
        if (nextToken == null) 'location': '$lat,$lng',
        if (nextToken == null) 'radius': '$radiusMeters',
        'language': 'tr',
        'region': 'tr',
        'key': apiKey,
      });

      final res = await _client.get(uri);
      if (res.statusCode != 200) {
        throw Exception('TextSearch HTTP ${res.statusCode}: ${res.body}');
      }

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final status = j['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        throw Exception('TextSearch status=$status body=${res.body}');
      }

      final results =
          (j['results'] as List? ?? []).cast<Map<String, dynamic>>();
      out.addAll(results.map(
          (e) => PlaceSummary.fromPlacesJson(e, category: category)));

      nextToken = j['next_page_token'] as String?;
      if (nextToken == null) break;
    }

    return out.where((e) => e.placeId.isNotEmpty).toList();
  }
}
