import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_places_service.dart';

class PlacesRepository {
  PlacesRepository({
    required GooglePlacesService places,
    Duration ttl = const Duration(days: 7),
  })  : _places = places,
        _ttl = ttl;

  final GooglePlacesService _places;
  final Duration _ttl;

  static const _vetsKey = "cache_vets_ankara_v2";
  static const _vetsTimeKey = "cache_vets_ankara_v2_time";

  static const _sheltersKey = "cache_shelters_ankara_v2";
  static const _sheltersTimeKey = "cache_shelters_ankara_v2_time";

  Future<List<PlaceSummary>> getAnkaraVets({
    int radiusMeters = 35000,
    bool forceRefresh = false,
  }) async {
    return _getCachedList(
      cacheKey: _vetsKey,
      cacheTimeKey: _vetsTimeKey,
      forceRefresh: forceRefresh,
      fetcher: () => _places.fetchAnkaraVets(radiusMeters: radiusMeters),
    );
  }

  Future<List<PlaceSummary>> getAnkaraShelters({
    int radiusMeters = 35000,
    bool forceRefresh = false,
  }) async {
    return _getCachedList(
      cacheKey: _sheltersKey,
      cacheTimeKey: _sheltersTimeKey,
      forceRefresh: forceRefresh,
      fetcher: () => _places.fetchAnkaraShelters(radiusMeters: radiusMeters),
    );
  }

  Future<List<PlaceSummary>> _getCachedList({
    required String cacheKey,
    required String cacheTimeKey,
    required bool forceRefresh,
    required Future<List<PlaceSummary>> Function() fetcher,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedJson = prefs.getString(cacheKey);
      final cachedTimeMs = prefs.getInt(cacheTimeKey);

      if (cachedJson != null && cachedTimeMs != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedTimeMs);
        final valid = DateTime.now().difference(cacheTime) < _ttl;

        if (valid) {
          final list =
              (jsonDecode(cachedJson) as List).cast<Map<String, dynamic>>();
          return list.map((e) => PlaceSummary.fromJson(e)).toList();
        }
      }
    }

    final fresh = await fetcher();

    await prefs.setString(
      cacheKey,
      jsonEncode(fresh.map((e) => e.toJson()).toList()),
    );
    await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

    return fresh;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vetsKey);
    await prefs.remove(_vetsTimeKey);
    await prefs.remove(_sheltersKey);
    await prefs.remove(_sheltersTimeKey);
  }
}
