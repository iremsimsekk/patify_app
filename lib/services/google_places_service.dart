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
  final String? email;
  final String? phone;
  final String? internationalPhoneNumber;
  final String? website;
  final double? rating;
  final int? userRatingsTotal;
  final List<String>? openingHours;
  final String? googleMapsUrl;
  final String? photoReference;
  final PlaceCategory category;

  PlaceSummary({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.category,
    this.address,
    this.email,
    this.phone,
    this.internationalPhoneNumber,
    this.website,
    this.rating,
    this.userRatingsTotal,
    this.openingHours,
    this.googleMapsUrl,
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
      email: json['email'] as String?,
      phone: json['formatted_phone_number'] as String?,
      internationalPhoneNumber: json['international_phone_number'] as String?,
      website: json['website'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
      openingHours: _readStringList(
        json['opening_hours']?['weekday_text'] ?? json['opening_hours'],
      ),
      googleMapsUrl: (json['url'] ?? json['google_maps_url']) as String?,
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
        'email': email,
        'phone': phone,
        'internationalPhoneNumber': internationalPhoneNumber,
        'website': website,
        'rating': rating,
        'userRatingsTotal': userRatingsTotal,
        'openingHours': openingHours,
        'googleMapsUrl': googleMapsUrl,
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
      email: json['email'] as String?,
      phone: _readString(json, ['phone']),
      internationalPhoneNumber: _readString(
        json,
        ['internationalPhoneNumber', 'international_phone_number'],
      ),
      website: _readString(json, ['website']),
      rating: _readDouble(json, ['rating']),
      userRatingsTotal: _readInt(
        json,
        ['userRatingsTotal', 'user_rating_count', 'userRatingsTotal'],
      ),
      openingHours: _readStringList(
        _readDynamic(json, ['openingHours', 'opening_hours']),
      ),
      googleMapsUrl: _readString(
        json,
        ['googleMapsUrl', 'google_maps_url'],
      ),
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
  final String? internationalPhoneNumber;
  final String? email;
  final String? website;
  final double? rating;
  final int? userRatingsTotal;
  final List<String>? weekdayText;
  final String? googleMapsUrl;
  final String? description;
  final String? city;
  final String? district;

  PlaceDetails({
    required this.placeId,
    required this.name,
    this.formattedAddress,
    this.phone,
    this.internationalPhoneNumber,
    this.email,
    this.website,
    this.rating,
    this.userRatingsTotal,
    this.weekdayText,
    this.googleMapsUrl,
    this.description,
    this.city,
    this.district,
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
      internationalPhoneNumber: result['international_phone_number'] as String?,
      email: result['email'] as String?,
      website: result['website'] as String?,
      rating: (result['rating'] as num?)?.toDouble(),
      userRatingsTotal: result['user_ratings_total'] as int?,
      weekdayText: weekday,
      googleMapsUrl: result['url'] as String?,
      description: result['description'] as String?,
      city: result['city'] as String?,
      district: result['district'] as String?,
    );
  }
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  }
  return null;
}

dynamic _readDynamic(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) {
      return json[key];
    }
  }
  return null;
}

double? _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
  }
  return null;
}

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
  }
  return null;
}

List<String>? _readStringList(dynamic value) {
  if (value is List) {
    final items =
        value.map((entry) => entry?.toString()).whereType<String>().toList();
    return items.isEmpty ? null : items;
  }
  if (value is String && value.trim().isNotEmpty) {
    return [value];
  }
  return null;
}

class GooglePlacesService {
  GooglePlacesService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  static const _textUrl =
      'https://maps.googleapis.com/maps/api/place/textsearch/json';
  static const _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  static const ankaraLat = 39.92077;
  static const ankaraLng = 32.85411;
  static const _ankaraDistricts = [
    'cankaya',
    'yenimahalle',
    'kecioren',
    'mamak',
    'etimesgut',
    'sincan',
    'golbasi',
    'altindag',
    'pursaklar',
    'akyurt',
    'cubuk',
    'kahramankazan',
    'elmadag',
    'bala',
    'haymana',
    'polatli',
    'beypazari',
    'nallihan',
    'ayas',
    'gudul',
    'kalecik',
    'kizilcahamam',
    'camlidere',
    'evren',
    'sereflikochisar',
  ];

  Future<List<PlaceSummary>> fetchAnkaraVets({int radiusMeters = 35000}) async {
    return _fetchAcrossQueries(
      queries: [
        'veteriner ankara',
        'veterinary clinic ankara',
        ..._ankaraDistricts.map((district) => 'veteriner $district ankara'),
        ..._ankaraDistricts
            .map((district) => 'veterinary clinic $district ankara'),
      ],
      lat: ankaraLat,
      lng: ankaraLng,
      radiusMeters: radiusMeters,
      category: PlaceCategory.vet,
    );
  }

  Future<List<PlaceSummary>> fetchAnkaraShelters({
    int radiusMeters = 35000,
  }) async {
    return _fetchAcrossQueries(
      queries: [
        'hayvan barinagi ankara',
        'animal shelter ankara',
        ..._ankaraDistricts
            .map((district) => 'hayvan barinagi $district ankara'),
        ..._ankaraDistricts
            .map((district) => 'animal shelter $district ankara'),
      ],
      lat: ankaraLat,
      lng: ankaraLng,
      radiusMeters: radiusMeters,
      category: PlaceCategory.shelter,
    );
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
      throw Exception(
        'Place Details HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final status = json['status'] as String?;
    if (status != 'OK') {
      throw Exception('Place Details status=$status, body=${response.body}');
    }
    return PlaceDetails.fromJson(json);
  }

  Future<List<PlaceSummary>> _fetchAcrossQueries({
    required List<String> queries,
    required double lat,
    required double lng,
    required int radiusMeters,
    required PlaceCategory category,
  }) async {
    final merged = <String, PlaceSummary>{};

    for (final query in queries) {
      final results = await _singlePageTextSearch(
        query: query,
        lat: lat,
        lng: lng,
        radiusMeters: radiusMeters,
        category: category,
      );

      for (final place in results) {
        if (place.placeId.isNotEmpty) {
          merged[place.placeId] = place;
        }
      }
    }

    final values = merged.values.toList();
    values.sort((a, b) {
      final aRating = a.rating ?? -1;
      final bRating = b.rating ?? -1;
      final ratingCompare = bRating.compareTo(aRating);
      if (ratingCompare != 0) return ratingCompare;
      return a.name.compareTo(b.name);
    });
    return values;
  }

  Future<List<PlaceSummary>> _singlePageTextSearch({
    required String query,
    required double lat,
    required double lng,
    required int radiusMeters,
    required PlaceCategory category,
  }) async {
    final uri = Uri.parse(_textUrl).replace(
      queryParameters: {
        'query': query,
        'location': '$lat,$lng',
        'radius': '$radiusMeters',
        'language': 'tr',
        'region': 'tr',
        'key': apiKey,
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'TextSearch HTTP ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final status = json['status'] as String?;
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception('TextSearch status=$status body=${response.body}');
    }

    final results =
        (json['results'] as List? ?? []).cast<Map<String, dynamic>>();
    return results
        .map((entry) => PlaceSummary.fromPlacesJson(entry, category: category))
        .where((entry) => entry.placeId.isNotEmpty)
        .toList();
  }
}
