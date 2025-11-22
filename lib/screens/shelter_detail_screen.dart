// Dosya: lib/screens/shelter_detail_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/pet_card.dart';
import 'animal_detail_screen.dart';

class ShelterDetailScreen extends StatelessWidget {
  final AppUser shelter;

  const ShelterDetailScreen({super.key, required this.shelter});

  @override
  Widget build(BuildContext context) {
    final animals = getAnimalsByShelter(shelter.id);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(shelter.name, style: const TextStyle(fontSize: 18))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barınak Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.store, size: 40, color: Colors.black54)),
                  const SizedBox(height: 16),
                  Text(shelter.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  
                  // Google Maps Tarzı Rating Gösterimi
                  if (shelter.rating != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(shelter.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const Icon(Icons.star_half, color: Colors.orange, size: 16),
                        Text(" (${shelter.reviewCount})", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                  Text(shelter.address ?? "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 20),
                  
                  // İletişim Butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(Icons.call, "Ara", theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      _buildActionButton(Icons.map, "Yol Tarifi", theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      _buildActionButton(Icons.language, "Web", theme.colorScheme.primary),
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
                  Text(shelter.about ?? "Bilgi yok.", style: const TextStyle(color: Colors.black87, height: 1.5)),
                  const SizedBox(height: 16),
                  if (shelter.workingHours != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("Çalışma Saatleri: ${shelter.workingHours}", style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                ],
              ),
            ),

            const Divider(indent: 20, endIndent: 20),

            // Hayvan Listesi
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Text("Dostlarımız (${animals.length})", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),

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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnimalDetailScreen(animal: animal))),
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
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}