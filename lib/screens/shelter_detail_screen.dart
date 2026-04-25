// Dosya: lib/screens/shelter_detail_screen.dart (GÜNCELLENDİ - Google Places ile)
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/pet_card.dart';
import '../services/google_places_service.dart';
import '../services/institution_api_service.dart';
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

  @override
  Widget build(BuildContext context) {
    // ✅ placeId ile ilanları çekiyoruz (şimdilik boş olabilir)
    final animals = getAnimalsByShelter(widget.placeId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontSize: 18))),
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

          final d = snap.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barınak Header (UI aynı)
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
                        child: Icon(Icons.store, size: 40, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        d.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Rating (Google’dan)
                      if (d.rating != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              d.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            Text(" (${d.userRatingsTotal ?? 0})", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),

                      const SizedBox(height: 8),

                      Text(
                        d.formattedAddress ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),

                      const SizedBox(height: 20),

                      // İletişim Butonları (şimdilik UI aynı, aksiyonları sonra bağlarız)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionButton(Icons.call, "Ara", theme.colorScheme.primary, onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ara özelliği: sonraki adımda bağlayacağız.")),
                            );
                          }),
                          const SizedBox(width: 16),
                          _buildActionButton(Icons.map, "Yol Tarifi", theme.colorScheme.primary, onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Yol tarifi: sonraki adımda bağlayacağız.")),
                            );
                          }),
                          const SizedBox(width: 16),
                          _buildActionButton(Icons.language, "Web", theme.colorScheme.primary, onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Web açma: sonraki adımda bağlayacağız.")),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                // Hakkımızda
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Kurum Hakkında", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        "Bu kurum bilgileri Google Places üzerinden alınır. Bazı alanlar işletmeye göre eksik olabilir.",
                        style: TextStyle(color: Colors.black87, height: 1.5),
                      ),
                      const SizedBox(height: 16),

                      // Çalışma saatleri (Google’dan)
                      if (d.weekdayText != null && d.weekdayText!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.access_time, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Çalışma Saatleri:\n${d.weekdayText!.join("\n")}",
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const Divider(indent: 20, endIndent: 20),

                // Hayvan Listesi (placeId ile - şimdilik boş olabilir)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    "Dostlarımız (${animals.length})",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                if (animals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("Bu barınağa ait ilan bulunamadı.", style: TextStyle(color: Colors.grey)),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          MaterialPageRoute(builder: (_) => AnimalDetailScreen(animal: animal)),
                        ),
                        child: PetCard(
                          name: animal.name,
                          age: animal.breed,
                          imagePath: animal.imagePath,
                          backgroundColor: theme.cardTheme.color ?? Colors.white,
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

  Widget _buildActionButton(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
