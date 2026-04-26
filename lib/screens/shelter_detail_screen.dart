import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/google_places_service.dart';
import '../services/institution_api_service.dart';
import '../widgets/pet_card.dart';
import 'animal_detail_screen.dart';

class ShelterDetailScreen extends StatefulWidget {
  final String apiKey;
  final String placeId;
  final String title;

  const ShelterDetailScreen({
    super.key,
    required this.apiKey,
    required this.placeId,
    required this.title,
  });

  @override
  State<ShelterDetailScreen> createState() => _ShelterDetailScreenState();
}

class _ShelterDetailScreenState extends State<ShelterDetailScreen> {
  late final Future<PlaceDetails> _future;

  @override
  void initState() {
    super.initState();
    _future = InstitutionApiService.fetchInstitutionDetails(widget.placeId);
  }

  String _valueOrFallback(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Bilgi yok";
    }
    return value;
  }

  String _ratingText(PlaceDetails details) {
    final rating = details.rating;
    if (rating == null) {
      return "Bilgi yok";
    }

    final count = details.userRatingsTotal;
    if (count == null) {
      return rating.toStringAsFixed(1);
    }
    return "${rating.toStringAsFixed(1)} ($count değerlendirme)";
  }

  @override
  Widget build(BuildContext context) {
    final animals = getAnimalsByShelter(widget.placeId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontSize: 18))),
      body: FutureBuilder<PlaceDetails>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError || snap.data == null) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text("Detay alınamadı: ${snap.error}"),
            );
          }

          final details = snap.data!;
          final openingHours = details.weekdayText ?? const <String>[];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child:
                            Icon(Icons.store, size: 40, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        details.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _ratingText(details),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _valueOrFallback(details.formattedAddress),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionButton(
                              Icons.call, "Ara", theme.colorScheme.primary),
                          const SizedBox(width: 16),
                          _buildActionButton(Icons.map, "Yol Tarifi",
                              theme.colorScheme.primary),
                          const SizedBox(width: 16),
                          _buildActionButton(
                              Icons.language, "Web", theme.colorScheme.primary),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(Icons.phone, "Telefon",
                          _valueOrFallback(details.phone)),
                      if (details.website != null &&
                          details.website!.trim().isNotEmpty)
                        _detailRow(
                            Icons.language, "Web Sitesi", details.website!),
                      _detailRow(
                          Icons.star_outline, "Puan", _ratingText(details)),
                      _detailRow(
                        Icons.map_outlined,
                        "Google Maps",
                        _valueOrFallback(details.googleMapsUrl),
                      ),
                      _detailRow(
                        Icons.location_on_outlined,
                        "Adres",
                        _valueOrFallback(details.formattedAddress),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.access_time,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              openingHours.isEmpty
                                  ? "Çalışma Saatleri: Bilgi yok"
                                  : "Çalışma Saatleri:\n${openingHours.join("\n")}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(indent: 20, endIndent: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    "Dostlarımız (${animals.length})",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if (animals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      "Bu barınağa ait ilan bulunamadı.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: animals.length,
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnimalDetailScreen(animal: animal),
                          ),
                        ),
                        child: PetCard(
                          name: animal.name,
                          age: animal.breed,
                          imagePath: animal.imagePath,
                          backgroundColor:
                              theme.cardTheme.color ?? Colors.white,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("$label bilgisi detay kartında gösteriliyor.")),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
