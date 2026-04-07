import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/google_places_service.dart';

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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _markers.clear();
        _errorMessage = 'Harita verileri yuklenemedi. Lutfen tekrar dene.';
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
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
      builder: (_) => SafeArea(
        child: ListTile(
          title: Text(place.name),
          subtitle: Text(place.address ?? ''),
          trailing: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openDetails(place);
            },
            child: const Text('Detay'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ankara Haritasi'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
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
          if (_errorMessage != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(_errorMessage!),
                  ),
                ),
              ),
            ),
          if (_loading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Google Places verileri yukleniyor...'),
                  ),
                ),
              ),
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
              padding: const EdgeInsets.all(16),
              child: Text('Detay alinamadi: ${snap.error}'),
            );
          }
          if (!snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Detay verisi bulunamadi.'),
            );
          }

          final details = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                details.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if (details.formattedAddress != null)
                Text('Adres: ${details.formattedAddress}'),
              if (details.phone != null) Text('Telefon: ${details.phone}'),
              if (details.website != null) Text('Website: ${details.website}'),
              if (details.rating != null)
                Text(
                  'Puan: ${details.rating} (${details.userRatingsTotal ?? 0} oy)',
                ),
              const SizedBox(height: 12),
              if (details.weekdayText != null && details.weekdayText!.isNotEmpty)
                ...[
                  Text(
                    'Calisma Saatleri',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  ...details.weekdayText!.map((entry) => Text('- $entry')),
                ],
            ],
          );
        },
      ),
    );
  }
}
