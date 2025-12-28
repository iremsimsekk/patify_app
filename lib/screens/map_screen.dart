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

  static const _ankara = LatLng(GooglePlacesService.ankaraLat, GooglePlacesService.ankaraLng);

  @override
  void initState() {
    super.initState();
    _places = GooglePlacesService(apiKey: widget.apiKey);
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => _loading = true);

      final vets = await _places.fetchAnkaraVets(radiusMeters: 35000);
      final shelters = await _places.fetchAnkaraShelters(radiusMeters: 35000);

      final markers = <Marker>{};

      for (final p in vets) {
        markers.add(_markerFor(p, hue: BitmapDescriptor.hueRed));
      }
      for (final p in shelters) {
        markers.add(_markerFor(p, hue: BitmapDescriptor.hueAzure));
      }

      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Marker _markerFor(PlaceSummary p, {required double hue}) {
    return Marker(
      markerId: MarkerId('${p.category.name}_${p.placeId}'),
      position: LatLng(p.lat, p.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: p.name,
        snippet: p.address,
        onTap: () => _openDetails(p),
      ),
      onTap: () => _openBottomSheet(p),
    );
  }

  void _openBottomSheet(PlaceSummary p) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListTile(
          title: Text(p.name),
          subtitle: Text(p.address ?? ''),
          trailing: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openDetails(p);
            },
            child: const Text('Detay'),
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(PlaceSummary p) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailsScreen(
          places: _places,
          summary: p,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ankara Haritası'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: _ankara, zoom: 11),
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),
          if (_loading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Google Places verileri yükleniyor...'),
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
              child: Text('Detay alınamadı: ${snap.error}'),
            );
          }

          final d = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(d.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              if (d.formattedAddress != null) Text('Adres: ${d.formattedAddress}'),
              if (d.phone != null) Text('Telefon: ${d.phone}'),
              if (d.website != null) Text('Website: ${d.website}'),
              if (d.rating != null)
                Text('Puan: ${d.rating} (${d.userRatingsTotal ?? 0} oy)'),
              const SizedBox(height: 12),
              if (d.weekdayText != null && d.weekdayText!.isNotEmpty) ...[
                Text('Çalışma Saatleri', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                ...d.weekdayText!.map((e) => Text('• $e')),
              ],
            ],
          );
        },
      ),
    );
  }
}
