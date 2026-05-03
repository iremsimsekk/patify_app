import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/mock_data.dart';
import '../services/google_places_service.dart';
import '../services/institution_api_service.dart';
import '../services/lost_report_service.dart';
import '../theme/patify_theme.dart';
import 'lost_report_detail_screen.dart';
import 'shelter_detail_screen.dart';
import 'veterinary_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.apiKey,
    required this.currentUser,
  });

  final String apiKey;
  final AppUser currentUser;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = <Marker>{};

  List<PlaceSummary> _clinics = const <PlaceSummary>[];
  List<PlaceSummary> _shelters = const <PlaceSummary>[];
  List<LostReport> _lostReports = const <LostReport>[];
  List<_NearbyMapItem> _nearbyItems = const <_NearbyMapItem>[];

  bool _loading = true;
  bool _isMapReady = false;
  bool _didFitBounds = false;
  bool _myLocationEnabled = false;
  bool _showVeterinarians = true;
  bool _showShelters = true;
  bool _showLostPets = true;
  String? _errorMessage;
  String? _locationMessage;
  _ResolvedPosition? _resolvedPosition;

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
      final lostReportsFuture = LostReportService.activeReports(
        email: widget.currentUser.email,
      );
      final locationFuture = _resolveUserPosition();

      final clinics = await clinicsFuture;
      final shelters = await sheltersFuture;
      final lostReports = await lostReportsFuture;
      final position = await locationFuture;

      final validClinics =
          clinics.where(_hasValidCoordinates).toList(growable: false);
      final validShelters =
          shelters.where(_hasValidCoordinates).toList(growable: false);
      final validLostReports =
          lostReports.where(_hasValidLostReportCoordinates).toList(
                growable: false,
              );
      final markers = _buildFilteredMarkers(
        clinics: validClinics,
        shelters: validShelters,
        lostReports: validLostReports,
      );
      final nearbyItems = _buildFilteredNearbyItems(
        clinics: validClinics,
        shelters: validShelters,
        lostReports: validLostReports,
        originLat: position.latitude,
        originLng: position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _clinics = validClinics;
        _shelters = validShelters;
        _lostReports = validLostReports;
        _nearbyItems = nearbyItems;
        _markers
          ..clear()
          ..addAll(markers);
        _myLocationEnabled = position.isPreciseUserLocation;
        _locationMessage = position.message;
        _resolvedPosition = position;
      });

      _fitBoundsIfPossible();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Harita ve acil veteriner verileri yuklenemedi. Backend baglantisini kontrol edip tekrar dene.';
        _clinics = const <PlaceSummary>[];
        _shelters = const <PlaceSummary>[];
        _lostReports = const <LostReport>[];
        _nearbyItems = const <_NearbyMapItem>[];
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

  bool _hasValidLostReportCoordinates(LostReport report) {
    return report.latitude != 0 || report.longitude != 0;
  }

  Set<Marker> _buildFilteredMarkers({
    required List<PlaceSummary> clinics,
    required List<PlaceSummary> shelters,
    required List<LostReport> lostReports,
  }) {
    final markers = <Marker>{};

    for (final clinic in _showVeterinarians ? clinics : <PlaceSummary>[]) {
      markers.add(_markerFor(clinic, hue: BitmapDescriptor.hueRose));
    }
    for (final shelter in _showShelters ? shelters : <PlaceSummary>[]) {
      markers.add(_markerFor(shelter, hue: BitmapDescriptor.hueAzure));
    }
    for (final report in _showLostPets ? lostReports : <LostReport>[]) {
      markers.add(_lostReportMarkerFor(report));
    }

    return markers;
  }

  void _applyFilters() {
    final position = _resolvedPosition;
    setState(() {
      _didFitBounds = false;
      _markers
        ..clear()
        ..addAll(
          _buildFilteredMarkers(
            clinics: _clinics,
            shelters: _shelters,
            lostReports: _lostReports,
          ),
        );
      if (position != null) {
        _nearbyItems = _buildFilteredNearbyItems(
          clinics: _clinics,
          shelters: _shelters,
          lostReports: _lostReports,
          originLat: position.latitude,
          originLng: position.longitude,
        );
      }
    });
    _fitBoundsIfPossible();
  }

  void _setFilter(_MapFilter filter, bool selected) {
    switch (filter) {
      case _MapFilter.veterinarian:
        _showVeterinarians = selected;
      case _MapFilter.shelter:
        _showShelters = selected;
      case _MapFilter.lostPet:
        _showLostPets = selected;
    }
    _applyFilters();
  }

  void _showAllFilters() {
    _showVeterinarians = true;
    _showShelters = true;
    _showLostPets = true;
    _applyFilters();
  }

  Marker _lostReportMarkerFor(LostReport report) {
    return Marker(
      markerId: MarkerId('lost_report_${report.id}'),
      position: LatLng(report.latitude, report.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
        title: 'Kayıp ${report.petType}',
        snippet: report.address ?? report.district ?? 'Ankara',
        onTap: () => _openLostReportDetail(report),
      ),
      onTap: () => _openLostReportSheet(report),
    );
  }

  Marker _markerFor(PlaceSummary place, {required double hue}) {
    final ratingText =
        place.rating != null ? ' - ${place.rating!.toStringAsFixed(1)}' : '';
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
      onTap: () => _openPlaceSheet(place),
    );
  }

  Future<_ResolvedPosition> _resolveUserPosition() async {
    if (!_supportsMap) {
      return const _ResolvedPosition(
        latitude: 39.9334,
        longitude: 32.8597,
        isPreciseUserLocation: false,
        message: 'Harita mobil ve web uzerinde desteklenir.',
      );
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const _ResolvedPosition(
          latitude: 39.9334,
          longitude: 32.8597,
          isPreciseUserLocation: false,
          message: 'Konum servisi kapali. Harita Ankara merkezi gosteriyor.',
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
          message: 'Konum izni verilmedi. Harita Ankara merkezi gosteriyor.',
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
    } catch (_) {
      return const _ResolvedPosition(
        latitude: 39.9334,
        longitude: 32.8597,
        isPreciseUserLocation: false,
        message: 'Konum alinamadi. Harita Ankara merkezi gosteriyor.',
      );
    }
  }

  List<_NearbyMapItem> _buildFilteredNearbyItems({
    required List<PlaceSummary> clinics,
    required List<PlaceSummary> shelters,
    required List<LostReport> lostReports,
    required double originLat,
    required double originLng,
  }) {
    final items = <_NearbyMapItem>[
      if (_showVeterinarians)
        ...clinics.map(
          (clinic) => _NearbyMapItem.place(
            place: clinic,
            type: _MapFilter.veterinarian,
            distanceMeters: Geolocator.distanceBetween(
              originLat,
              originLng,
              clinic.lat,
              clinic.lng,
            ),
          ),
        ),
      if (_showShelters)
        ...shelters.map(
          (shelter) => _NearbyMapItem.place(
            place: shelter,
            type: _MapFilter.shelter,
            distanceMeters: Geolocator.distanceBetween(
              originLat,
              originLng,
              shelter.lat,
              shelter.lng,
            ),
          ),
        ),
      if (_showLostPets)
        ...lostReports.map(
          (report) => _NearbyMapItem.lostReport(
            report: report,
            distanceMeters: Geolocator.distanceBetween(
              originLat,
              originLng,
              report.latitude,
              report.longitude,
            ),
          ),
        ),
    ];

    items.sort(
      (left, right) => left.distanceMeters.compareTo(right.distanceMeters),
    );
    return items.take(12).toList(growable: false);
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

  void _openPlaceSheet(PlaceSummary place) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: PatifyTheme.space8),
              Text(place.address ?? 'Adres bilgisi yok'),
              const SizedBox(height: PatifyTheme.space8),
              Wrap(
                spacing: PatifyTheme.space8,
                runSpacing: PatifyTheme.space8,
                children: [
                  _MetaPill(
                    label: place.category == PlaceCategory.shelter
                        ? 'Barinak'
                        : 'Veteriner',
                    icon: place.category == PlaceCategory.shelter
                        ? Icons.home_work_outlined
                        : Icons.local_hospital_outlined,
                  ),
                  if (place.phone != null && place.phone!.trim().isNotEmpty)
                    _MetaPill(
                      label: place.phone!,
                      icon: Icons.phone_outlined,
                    ),
                  if (place.rating != null)
                    _MetaPill(
                      label: place.userRatingsTotal != null
                          ? '${place.rating!.toStringAsFixed(1)} (${place.userRatingsTotal})'
                          : place.rating!.toStringAsFixed(1),
                      icon: Icons.star_outline,
                    ),
                ],
              ),
              const SizedBox(height: PatifyTheme.space16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _launchPhone(place.phone),
                      child: const Text('Ara'),
                    ),
                  ),
                  const SizedBox(width: PatifyTheme.space8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _launchDirections(place),
                      child: const Text('Yol Tarifi Al'),
                    ),
                  ),
                  const SizedBox(width: PatifyTheme.space8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _openDetails(place);
                    },
                    child: const Text('Detay'),
                  ),
                ],
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

  void _openLostReportSheet(LostReport report) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kayıp ${report.petType}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: PatifyTheme.space8),
              Text(report.address ?? report.district ?? 'Adres bilgisi yok'),
              const SizedBox(height: PatifyTheme.space8),
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: PatifyTheme.space16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _launchLostReportDirections(report),
                      child: const Text('Yol Tarifi'),
                    ),
                  ),
                  const SizedBox(width: PatifyTheme.space8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _openLostReportDetail(report);
                      },
                      child: const Text('Detay'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLostReportDetail(LostReport report) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LostReportDetailScreen(
          reportId: report.id,
          currentUser: widget.currentUser,
        ),
      ),
    );
    _load();
  }

  Future<void> _launchPhone(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu kurum icin telefon bilgisi bulunmuyor.'),
        ),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone.trim());
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arama baslatilamadi.')),
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
        const SnackBar(content: Text('Yol tarifi acilamadi.')),
      );
    }
  }

  Future<void> _launchLostReportDirections(LostReport report) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${report.latitude},${report.longitude}';
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yol tarifi acilamadi.')),
      );
    }
  }

  Future<void> _launchNearbyDirections(_NearbyMapItem item) {
    final place = item.place;
    if (place != null) {
      return _launchDirections(place);
    }

    return _launchLostReportDirections(item.report!);
  }

  Future<void> _openNearbyDetail(_NearbyMapItem item) {
    final place = item.place;
    if (place != null) {
      return _openDetails(place);
    }

    return _openLostReportDetail(item.report!);
  }

  Future<void> _openNearbyItemsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _NearbyItemsScreen(
          nearbyItems: _nearbyItems,
          loading: _loading,
          errorMessage: _errorMessage,
          onRetry: _load,
          onCall: _launchPhone,
          onDirections: _launchNearbyDirections,
          onOpenDetails: _openNearbyDetail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harita'),
        actions: [
          TextButton.icon(
            onPressed: _openNearbyItemsPage,
            icon: const Icon(Icons.near_me_outlined),
            label: const Text('Yakındakiler'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: _load,
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: !_supportsMap
          ? _DesktopFallback(
              errorMessage: _errorMessage,
              locationMessage: _locationMessage,
              nearbyItems: _nearbyItems,
              onRetry: _load,
              onCall: _launchPhone,
              onDirections: _launchNearbyDirections,
              onOpenDetails: _openNearbyDetail,
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _ankaraCenter,
                    zoom: 11,
                  ),
                  mapType: MapType.normal,
                  liteModeEnabled: false,
                  markers: _markers,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                  indoorViewEnabled: true,
                  buildingsEnabled: true,
                  myLocationEnabled: _myLocationEnabled,
                  myLocationButtonEnabled: _myLocationEnabled,
                  gestureRecognizers: const {
                    Factory<OneSequenceGestureRecognizer>(
                      EagerGestureRecognizer.new,
                    ),
                  },
                  onMapCreated: (controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                    _isMapReady = true;
                    _fitBoundsIfPossible();
                  },
                  onTap: (_) {},
                ),
                _MapFilterBar(
                  showVeterinarians: _showVeterinarians,
                  showShelters: _showShelters,
                  showLostPets: _showLostPets,
                  onChanged: _setFilter,
                  onShowAll: _showAllFilters,
                ),
                if (_errorMessage != null)
                  _StatusBanner(
                    icon: Icons.error_outline_rounded,
                    text: _errorMessage!,
                    toneColor: PatifyTheme.danger,
                    top: 74,
                  ),
                if (_loading)
                  const _StatusBanner(
                    icon: Icons.location_searching_rounded,
                    text: 'Noktalar ve acil veterinerler yukleniyor...',
                    toneColor: PatifyTheme.primary,
                    top: 130,
                  ),
              ],
            ),
    );
  }
}

enum _MapFilter { veterinarian, shelter, lostPet }

class _MapFilterBar extends StatelessWidget {
  const _MapFilterBar({
    required this.showVeterinarians,
    required this.showShelters,
    required this.showLostPets,
    required this.onChanged,
    required this.onShowAll,
  });

  final bool showVeterinarians;
  final bool showShelters;
  final bool showLostPets;
  final void Function(_MapFilter filter, bool selected) onChanged;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        PatifyTheme.space12,
        PatifyTheme.space12,
        PatifyTheme.space12,
        0,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Card(
          margin: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: PatifyTheme.space8,
              vertical: PatifyTheme.space4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.layers_outlined, size: 18),
                  label: const Text('Tümü'),
                  onPressed: onShowAll,
                ),
                const SizedBox(width: PatifyTheme.space8),
                _FilterChip(
                  label: 'Vet',
                  icon: Icons.local_hospital_outlined,
                  selected: showVeterinarians,
                  onSelected: (selected) =>
                      onChanged(_MapFilter.veterinarian, selected),
                ),
                const SizedBox(width: PatifyTheme.space8),
                _FilterChip(
                  label: 'Barınak',
                  icon: Icons.home_work_outlined,
                  selected: showShelters,
                  onSelected: (selected) =>
                      onChanged(_MapFilter.shelter, selected),
                ),
                const SizedBox(width: PatifyTheme.space8),
                _FilterChip(
                  label: 'Kayıp',
                  icon: Icons.pets_outlined,
                  selected: showLostPets,
                  onSelected: (selected) =>
                      onChanged(_MapFilter.lostPet, selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      avatar: Icon(icon, size: 18),
      onSelected: onSelected,
      showCheckmark: false,
    );
  }
}

class _EmergencyPanel extends StatelessWidget {
  const _EmergencyPanel({
    required this.nearbyItems,
    required this.loading,
    required this.errorMessage,
    required this.onCall,
    required this.onDirections,
    required this.onOpenDetails,
    this.showCardChrome = true,
  });

  final List<_NearbyMapItem> nearbyItems;
  final bool loading;
  final String? errorMessage;
  final Future<void> Function(String? phone) onCall;
  final Future<void> Function(_NearbyMapItem item) onDirections;
  final Future<void> Function(_NearbyMapItem item) onOpenDetails;
  final bool showCardChrome;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(PatifyTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yakındakiler',
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
          else if (nearbyItems.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Yakın oge bulunamadi.'),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: nearbyItems.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: PatifyTheme.space12),
                itemBuilder: (context, index) {
                  final item = nearbyItems[index];
                  final place = item.place;
                  final report = item.report;
                  final phone = place?.phone?.trim();
                  final rating = place?.rating;
                  final ratingCount = place?.userRatingsTotal;
                  final contactInfo = report?.contactInfo.trim();
                  return Container(
                    padding: const EdgeInsets.all(PatifyTheme.space12),
                    decoration: BoxDecoration(
                      color: PatifyTheme.backgroundSoft,
                      borderRadius: BorderRadius.circular(PatifyTheme.radius16),
                      border: Border.all(color: PatifyTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: PatifyTheme.space4),
                        Text(item.subtitle),
                        const SizedBox(height: PatifyTheme.space4),
                        Wrap(
                          spacing: PatifyTheme.space8,
                          runSpacing: PatifyTheme.space8,
                          children: [
                            _MetaPill(
                              label: item.distanceLabel,
                              icon: Icons.near_me_outlined,
                            ),
                            _MetaPill(
                              label: item.typeLabel,
                              icon: item.typeIcon,
                            ),
                            if (phone != null && phone.isNotEmpty)
                              _MetaPill(
                                label: phone,
                                icon: Icons.phone_outlined,
                              ),
                            if (contactInfo != null && contactInfo.isNotEmpty)
                              _MetaPill(
                                label: contactInfo,
                                icon: Icons.phone_outlined,
                              ),
                            if (rating != null)
                              _MetaPill(
                                label: ratingCount != null
                                    ? '${rating.toStringAsFixed(1)} ($ratingCount)'
                                    : rating.toStringAsFixed(1),
                                icon: Icons.star_outline,
                              ),
                          ],
                        ),
                        const SizedBox(height: PatifyTheme.space12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: phone == null || phone.isEmpty
                                    ? null
                                    : () => onCall(phone),
                                child: const Text('Ara'),
                              ),
                            ),
                            const SizedBox(width: PatifyTheme.space8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => onDirections(item),
                                child: const Text('Yol Tarifi Al'),
                              ),
                            ),
                            const SizedBox(width: PatifyTheme.space8),
                            TextButton(
                              onPressed: () => onOpenDetails(item),
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
    );

    if (!showCardChrome) {
      return SafeArea(top: false, child: content);
    }

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
          child: content,
        ),
      ),
    );
  }
}

class _DesktopFallback extends StatelessWidget {
  const _DesktopFallback({
    required this.errorMessage,
    required this.locationMessage,
    required this.nearbyItems,
    required this.onRetry,
    required this.onCall,
    required this.onDirections,
    required this.onOpenDetails,
  });

  final String? errorMessage;
  final String? locationMessage;
  final List<_NearbyMapItem> nearbyItems;
  final VoidCallback onRetry;
  final Future<void> Function(String? phone) onCall;
  final Future<void> Function(_NearbyMapItem item) onDirections;
  final Future<void> Function(_NearbyMapItem item) onOpenDetails;

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
                  'Harita mobil ve web uzerinde desteklenir',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: PatifyTheme.space8),
                const Text(
                  'Windows masaustunde uygulama cokmeden calismaya devam eder. Bu ekranda en yakin veterinerler listesini kullanabilirsin.',
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
          nearbyItems: nearbyItems,
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

class _NearbyItemsScreen extends StatelessWidget {
  const _NearbyItemsScreen({
    required this.nearbyItems,
    required this.loading,
    required this.errorMessage,
    required this.onRetry,
    required this.onCall,
    required this.onDirections,
    required this.onOpenDetails,
  });

  final List<_NearbyMapItem> nearbyItems;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Future<void> Function(String? phone) onCall;
  final Future<void> Function(_NearbyMapItem item) onDirections;
  final Future<void> Function(_NearbyMapItem item) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yakindaki Ogeler'),
        actions: [
          IconButton(
            onPressed: onRetry,
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _EmergencyPanel(
        nearbyItems: nearbyItems,
        loading: loading,
        errorMessage: errorMessage,
        onCall: onCall,
        onDirections: onDirections,
        onOpenDetails: onOpenDetails,
        showCardChrome: false,
      ),
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

class _NearbyMapItem {
  const _NearbyMapItem._({
    required this.type,
    required this.distanceMeters,
    this.place,
    this.report,
  });

  factory _NearbyMapItem.place({
    required PlaceSummary place,
    required _MapFilter type,
    required double distanceMeters,
  }) {
    return _NearbyMapItem._(
      type: type,
      place: place,
      distanceMeters: distanceMeters,
    );
  }

  factory _NearbyMapItem.lostReport({
    required LostReport report,
    required double distanceMeters,
  }) {
    return _NearbyMapItem._(
      type: _MapFilter.lostPet,
      report: report,
      distanceMeters: distanceMeters,
    );
  }

  final _MapFilter type;
  final PlaceSummary? place;
  final LostReport? report;
  final double distanceMeters;

  String get title {
    final place = this.place;
    if (place != null) {
      return place.name;
    }
    return 'Kayıp ${report!.petType}';
  }

  String get subtitle {
    final place = this.place;
    if (place != null) {
      return place.address ?? 'Adres bilgisi yok';
    }
    final lostReport = report!;
    return lostReport.address ?? lostReport.district ?? lostReport.description;
  }

  String get typeLabel {
    switch (type) {
      case _MapFilter.veterinarian:
        return 'Veteriner';
      case _MapFilter.shelter:
        return 'Barinak';
      case _MapFilter.lostPet:
        return 'Kayip Hayvan';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case _MapFilter.veterinarian:
        return Icons.local_hospital_outlined;
      case _MapFilter.shelter:
        return Icons.home_work_outlined;
      case _MapFilter.lostPet:
        return Icons.pets_outlined;
    }
  }

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
