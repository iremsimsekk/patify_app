import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/google_places_service.dart';
import '../services/institution_api_service.dart';
import '../theme/patify_theme.dart';
import 'shelter_detail_screen.dart';
import 'veterinary_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.apiKey});

  final String apiKey;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = <Marker>{};

  List<_NearbyClinic> _nearbyClinics = const <_NearbyClinic>[];

  bool _loading = true;
  bool _isMapReady = false;
  bool _didFitBounds = false;
  bool _myLocationEnabled = false;
  String? _errorMessage;
  String? _locationMessage;

  static const _ankaraCenter = LatLng(39.9334, 32.8597);

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _supportsMap {
    if (kIsWeb) {
      return true;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return false;
    }
  }

  Future<void> _load() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _locationMessage = null;
      _didFitBounds = false;
    });

    try {
      final clinicsFuture = InstitutionApiService.fetchClinics();
      final sheltersFuture = InstitutionApiService.fetchShelters();
      final locationFuture = _resolveUserPosition();

      final clinics = await clinicsFuture;
      final shelters = await sheltersFuture;
      final position = await locationFuture;

      final validClinics =
          clinics.where(_hasValidCoordinates).toList(growable: false);
      final validShelters =
          shelters.where(_hasValidCoordinates).toList(growable: false);
      final markers = _buildMarkers(validClinics, validShelters);
      final nearbyClinics = _buildNearbyClinics(
        clinics: validClinics,
        originLat: position.latitude,
        originLng: position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _nearbyClinics = nearbyClinics.take(5).toList(growable: false);
        _markers
          ..clear()
          ..addAll(markers);
        _myLocationEnabled = position.isPreciseUserLocation;
        _locationMessage = position.message;
      });

      _fitBoundsIfPossible();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            'Harita ve acil veteriner verileri yüklenemedi. Backend bağlantısını kontrol edip tekrar dene.';
        _nearbyClinics = const <_NearbyClinic>[];
        _markers.clear();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool _hasValidCoordinates(PlaceSummary place) {
    return place.lat != 0 || place.lng != 0;
  }

  Set<Marker> _buildMarkers(
    List<PlaceSummary> clinics,
    List<PlaceSummary> shelters,
  ) {
    final markers = <Marker>{};

    for (final clinic in clinics) {
      markers.add(_markerFor(clinic, hue: BitmapDescriptor.hueRed));
    }
    for (final shelter in shelters) {
      markers.add(_markerFor(shelter, hue: BitmapDescriptor.hueAzure));
    }

    return markers;
  }

  Marker _markerFor(PlaceSummary place, {required double hue}) {
    final ratingText =
        place.rating != null ? ' • ${place.rating!.toStringAsFixed(1)}' : '';
    final snippetBase = place.address?.trim().isNotEmpty == true
        ? place.address!.trim()
        : 'Adres bilgisi yok';

    return Marker(
      markerId: MarkerId('${place.category.name}_${place.placeId}'),
      position: LatLng(place.lat, place.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: place.name,
        snippet: '$snippetBase$ratingText',
        onTap: () => _openDetails(place),
      ),
      onTap: () => _openBottomSheet(place),
    );
  }

  Future<_ResolvedPosition> _resolveUserPosition() async {
    if (!_supportsMap) {
      return const _ResolvedPosition(
        latitude: 39.9334,
        longitude: 32.8597,
        isPreciseUserLocation: false,
        message: 'Harita mobil ve web üzerinde desteklenir.',
      );
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const _ResolvedPosition(
        latitude: 39.9334,
        longitude: 32.8597,
        isPreciseUserLocation: false,
        message: 'Konum servisi kapalı. Harita Ankara merkezi gösteriyor.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const _ResolvedPosition(
        latitude: 39.9334,
        longitude: 32.8597,
        isPreciseUserLocation: false,
        message: 'Konum izni verilmedi. Harita Ankara merkezi gösteriyor.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return _ResolvedPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      isPreciseUserLocation: true,
      message: null,
    );
  }

  List<_NearbyClinic> _buildNearbyClinics({
    required List<PlaceSummary> clinics,
    required double originLat,
    required double originLng,
  }) {
    final items = clinics
        .map(
          (clinic) => _NearbyClinic(
            place: clinic,
            distanceMeters: Geolocator.distanceBetween(
              originLat,
              originLng,
              clinic.lat,
              clinic.lng,
            ),
          ),
        )
        .toList(growable: false);

    items.sort(
        (left, right) => left.distanceMeters.compareTo(right.distanceMeters));
    return items;
  }

  Future<void> _fitBoundsIfPossible() async {
    if (!_supportsMap || !_isMapReady || _didFitBounds || _markers.isEmpty) {
      return;
    }

    final controller = await _mapController.future;
    final points =
        _markers.map((marker) => marker.position).toList(growable: false);

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: points.first, zoom: 12.5),
        ),
      );
      _didFitBounds = true;
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
    _didFitBounds = true;
  }

  void _openBottomSheet(PlaceSummary place) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PatifyTheme.space20,
            PatifyTheme.space8,
            PatifyTheme.space20,
            PatifyTheme.space20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: PatifyTheme.space8),
                    Text(place.address ?? 'Adres bilgisi yok'),
                    if (place.rating != null) ...[
                      const SizedBox(height: PatifyTheme.space8),
                      Text('Puan: ${place.rating!.toStringAsFixed(1)}'),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: PatifyTheme.space12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openDetails(place);
                },
                child: const Text('Detay'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(PlaceSummary place) async {
    if (!mounted) {
      return;
    }

    final page = place.category == PlaceCategory.shelter
        ? ShelterDetailScreen(
            apiKey: widget.apiKey,
            placeId: place.placeId,
            title: place.name,
          )
        : VeterinaryDetailScreen(
            apiKey: widget.apiKey,
            placeId: place.placeId,
            title: place.name,
          );

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _launchPhone(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bu kurum için telefon bilgisi bulunmuyor.')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone.trim());
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arama başlatılamadı.')),
      );
    }
  }

  Future<void> _launchDirections(PlaceSummary place) async {
    final url = place.googleMapsUrl?.trim().isNotEmpty == true
        ? place.googleMapsUrl!.trim()
        : 'https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}';

    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yol tarifi açılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Harita')),
      body: !_supportsMap
          ? _DesktopFallback(
              errorMessage: _errorMessage,
              locationMessage: _locationMessage,
              nearbyClinics: _nearbyClinics,
              onRetry: _load,
              onCall: _launchPhone,
              onDirections: _launchDirections,
              onOpenDetails: _openDetails,
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _ankaraCenter,
                    zoom: 11,
                  ),
                  markers: _markers,
                  myLocationEnabled: _myLocationEnabled,
                  myLocationButtonEnabled: _myLocationEnabled,
                  onMapCreated: (controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                    _isMapReady = true;
                    _fitBoundsIfPossible();
                  },
                ),
                Positioned(
                  left: PatifyTheme.space16,
                  right: PatifyTheme.space16,
                  top: PatifyTheme.space12,
                  child: Container(
                    padding: const EdgeInsets.all(PatifyTheme.space16),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(PatifyTheme.radius24),
                      border: Border.all(color: PatifyTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color:
                              PatifyTheme.textPrimary.withValues(alpha: 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ankara', style: theme.textTheme.bodyMedium),
                              const SizedBox(height: PatifyTheme.space4),
                              Text(
                                'Veterinerler ve barınaklar',
                                style: theme.textTheme.titleLarge,
                              ),
                              if (_locationMessage != null) ...[
                                const SizedBox(height: PatifyTheme.space8),
                                Text(
                                  _locationMessage!,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Yenile'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  _StatusBanner(
                    icon: Icons.error_outline_rounded,
                    text: _errorMessage!,
                    toneColor: PatifyTheme.danger,
                    top: 112,
                  ),
                if (_loading)
                  const _StatusBanner(
                    icon: Icons.location_searching_rounded,
                    text: 'Noktalar ve acil veterinerler yükleniyor...',
                    toneColor: PatifyTheme.primary,
                    top: 168,
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _EmergencyPanel(
                    nearbyClinics: _nearbyClinics,
                    loading: _loading,
                    errorMessage: _errorMessage,
                    onCall: _launchPhone,
                    onDirections: _launchDirections,
                    onOpenDetails: _openDetails,
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmergencyPanel extends StatelessWidget {
  const _EmergencyPanel({
    required this.nearbyClinics,
    required this.loading,
    required this.errorMessage,
    required this.onCall,
    required this.onDirections,
    required this.onOpenDetails,
  });

  final List<_NearbyClinic> nearbyClinics;
  final bool loading;
  final String? errorMessage;
  final Future<void> Function(String? phone) onCall;
  final Future<void> Function(PlaceSummary place) onDirections;
  final Future<void> Function(PlaceSummary place) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        PatifyTheme.space12,
        0,
        PatifyTheme.space12,
        PatifyTheme.space12,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: 260,
          child: Padding(
            padding: const EdgeInsets.all(PatifyTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acil durumda en yakın veterinerler',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: PatifyTheme.space8),
                if (loading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (nearbyClinics.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('Yakın veteriner bulunamadı.'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: nearbyClinics.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: PatifyTheme.space12),
                      itemBuilder: (context, index) {
                        final item = nearbyClinics[index];
                        final place = item.place;
                        return Container(
                          padding: const EdgeInsets.all(PatifyTheme.space12),
                          decoration: BoxDecoration(
                            color: PatifyTheme.backgroundSoft,
                            borderRadius:
                                BorderRadius.circular(PatifyTheme.radius16),
                            border: Border.all(color: PatifyTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(place.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: PatifyTheme.space4),
                              Text(place.address ?? 'Adres bilgisi yok'),
                              const SizedBox(height: PatifyTheme.space4),
                              Wrap(
                                spacing: PatifyTheme.space8,
                                runSpacing: PatifyTheme.space8,
                                children: [
                                  _MetaPill(
                                      label: item.distanceLabel,
                                      icon: Icons.near_me_outlined),
                                  if (place.phone != null &&
                                      place.phone!.trim().isNotEmpty)
                                    _MetaPill(
                                        label: place.phone!,
                                        icon: Icons.phone_outlined),
                                  if (place.rating != null)
                                    _MetaPill(
                                      label: place.userRatingsTotal != null
                                          ? '${place.rating!.toStringAsFixed(1)} (${place.userRatingsTotal})'
                                          : place.rating!.toStringAsFixed(1),
                                      icon: Icons.star_outline,
                                    ),
                                ],
                              ),
                              const SizedBox(height: PatifyTheme.space12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => onCall(place.phone),
                                      child: const Text('Ara'),
                                    ),
                                  ),
                                  const SizedBox(width: PatifyTheme.space8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => onDirections(place),
                                      child: const Text('Yol Tarifi Al'),
                                    ),
                                  ),
                                  const SizedBox(width: PatifyTheme.space8),
                                  TextButton(
                                    onPressed: () => onOpenDetails(place),
                                    child: const Text('Detay'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopFallback extends StatelessWidget {
  const _DesktopFallback({
    required this.errorMessage,
    required this.locationMessage,
    required this.nearbyClinics,
    required this.onRetry,
    required this.onCall,
    required this.onDirections,
    required this.onOpenDetails,
  });

  final String? errorMessage;
  final String? locationMessage;
  final List<_NearbyClinic> nearbyClinics;
  final VoidCallback onRetry;
  final Future<void> Function(String? phone) onCall;
  final Future<void> Function(PlaceSummary place) onDirections;
  final Future<void> Function(PlaceSummary place) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(PatifyTheme.space20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(PatifyTheme.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harita mobil ve web üzerinde desteklenir',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: PatifyTheme.space8),
                const Text(
                  'Windows masaüstünde uygulama çökmeden çalışmaya devam eder. Bu ekranda en yakın veterinerler listesini kullanabilirsin.',
                ),
                if (locationMessage != null) ...[
                  const SizedBox(height: PatifyTheme.space8),
                  Text(locationMessage!),
                ],
                if (errorMessage != null) ...[
                  const SizedBox(height: PatifyTheme.space8),
                  Text(errorMessage!),
                ],
                const SizedBox(height: PatifyTheme.space16),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Yenile'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PatifyTheme.space16),
        _EmergencyPanel(
          nearbyClinics: nearbyClinics,
          loading: false,
          errorMessage: errorMessage,
          onCall: onCall,
          onDirections: onDirections,
          onOpenDetails: onOpenDetails,
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PatifyTheme.space8,
        vertical: PatifyTheme.space4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: PatifyTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.text,
    required this.toneColor,
    required this.top,
  });

  final IconData icon;
  final String text;
  final Color toneColor;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: top,
          left: PatifyTheme.space12,
          right: PatifyTheme.space12,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PatifyTheme.space16,
              vertical: PatifyTheme.space12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: toneColor, size: 18),
                const SizedBox(width: PatifyTheme.space8),
                Flexible(child: Text(text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NearbyClinic {
  const _NearbyClinic({
    required this.place,
    required this.distanceMeters,
  });

  final PlaceSummary place;
  final double distanceMeters;

  String get distanceLabel {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toStringAsFixed(0)} m';
  }
}

class _ResolvedPosition {
  const _ResolvedPosition({
    required this.latitude,
    required this.longitude,
    required this.isPreciseUserLocation,
    required this.message,
  });

  final double latitude;
  final double longitude;
  final bool isPreciseUserLocation;
  final String? message;
}
