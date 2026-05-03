import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/patify_theme.dart';

class PickedLocation {
  const PickedLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _ankaraCenter = LatLng(39.9334, 32.8597);
  LatLng _selected = _ankaraCenter;

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      markerId: const MarkerId('lost_report_location'),
      position: _selected,
      draggable: true,
      onDragEnd: (value) => setState(() => _selected = value),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Konum Seç')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _ankaraCenter,
              zoom: 12,
            ),
            markers: {marker},
            onTap: (value) => setState(() => _selected = value),
            gestureRecognizers: const {
              Factory<OneSequenceGestureRecognizer>(
                EagerGestureRecognizer.new,
              ),
            },
          ),
          Positioned(
            left: PatifyTheme.space20,
            right: PatifyTheme.space20,
            bottom: PatifyTheme.space20,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                  context,
                  PickedLocation(
                    latitude: _selected.latitude,
                    longitude: _selected.longitude,
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Bu konumu kullan'),
            ),
          ),
        ],
      ),
    );
  }
}
