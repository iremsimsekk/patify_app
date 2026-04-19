import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/google_places_service.dart';
import '../theme/patify_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.apiKey});

  final String apiKey;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final GooglePlacesService _places;
  final Set<Marker> _markers = {};
  bool _loading = true;
  String? _errorMessage;

  static const _ankara = LatLng(
    GooglePlacesService.ankaraLat,
    GooglePlacesService.ankaraLng,
  );

  @override
  void initState() {
    super.initState();
    _places = GooglePlacesService(apiKey: widget.apiKey);
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final vets = await _places.fetchAnkaraVets(radiusMeters: 35000);
      final shelters = await _places.fetchAnkaraShelters(radiusMeters: 35000);

      final markers = <Marker>{};
      for (final place in vets) {
        markers.add(_markerFor(place, hue: BitmapDescriptor.hueRed));
      }
      for (final place in shelters) {
        markers.add(_markerFor(place, hue: BitmapDescriptor.hueAzure));
      }

      if (!mounted) return;
      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _markers.clear();
        _errorMessage = 'Harita verileri yüklenemedi. Lütfen tekrar dene.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Marker _markerFor(PlaceSummary place, {required double hue}) {
    return Marker(
      markerId: MarkerId('${place.category.name}_${place.placeId}'),
      position: LatLng(place.lat, place.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: place.name,
        snippet: place.address,
        onTap: () => _openDetails(place),
      ),
      onTap: () => _openBottomSheet(place),
    );
  }

  void _openBottomSheet(PlaceSummary place) {
    showModalBottomSheet(
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
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailsScreen(
          places: _places,
          summary: place,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Harita')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _ankara,
              zoom: 11,
            ),
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
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
                    color: PatifyTheme.textPrimary.withValues(alpha: 0.10),
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
            ),
          if (_loading)
            const _StatusBanner(
              icon: Icons.location_searching_rounded,
              text: 'Noktalar yükleniyor...',
              toneColor: PatifyTheme.primary,
            ),
        ],
      ),
    );
  }
}

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({
    super.key,
    required this.places,
    required this.summary,
  });

  final GooglePlacesService places;
  final PlaceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(summary.name)),
      body: FutureBuilder<PlaceDetails>(
        future: places.fetchDetails(summary.placeId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(PatifyTheme.space20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(PatifyTheme.space16),
                  child: Text('Detay bilgisi alınamadı: ${snap.error}'),
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(PatifyTheme.space20),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(PatifyTheme.space16),
                  child: Text('Detay bilgisi bulunamadı.'),
                ),
              ),
            );
          }

          final details = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              PatifyTheme.space20,
              PatifyTheme.space12,
              PatifyTheme.space20,
              PatifyTheme.space28,
            ),
            children: [
              Text(details.name, style: theme.textTheme.headlineMedium),
              const SizedBox(height: PatifyTheme.space16),
              if (details.formattedAddress != null)
                _DetailRow(label: 'Adres', value: details.formattedAddress!),
              if (details.phone != null)
                _DetailRow(label: 'Telefon', value: details.phone!),
              if (details.website != null)
                _DetailRow(label: 'Web sitesi', value: details.website!),
              if (details.rating != null)
                _DetailRow(
                  label: 'Puan',
                  value:
                      '${details.rating} (${details.userRatingsTotal ?? 0} değerlendirme)',
                ),
              const SizedBox(height: PatifyTheme.space16),
              if (details.weekdayText != null &&
                  details.weekdayText!.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(PatifyTheme.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Çalışma saatleri',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: PatifyTheme.space8),
                        ...details.weekdayText!.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: PatifyTheme.space8,
                            ),
                            child: Text(entry),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: PatifyTheme.space12),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: PatifyTheme.space16,
            vertical: PatifyTheme.space4,
          ),
          title: Text(label, style: theme.textTheme.bodyMedium),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: PatifyTheme.space4),
            child: Text(value, style: theme.textTheme.titleMedium),
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.text,
    required this.toneColor,
  });

  final IconData icon;
  final String text;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 88,
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
