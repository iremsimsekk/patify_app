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
      appBar: AppBar(title: Text(shelter.name)),
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
                  Text(shelter.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  Text(shelter.address ?? "", style: const TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 20),
                  
                  // İletişim Bilgileri (Yeni)
                  if (shelter.phoneNumber != null)
                    _buildContactRow(Icons.phone, shelter.phoneNumber!),
                  if (shelter.workingHours != null)
                    _buildContactRow(Icons.access_time, shelter.workingHours!),
                  if (shelter.website != null)
                    _buildContactRow(Icons.language, shelter.website!),
                ],
              ),
            ),
            
            // Hakkımızda
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Hakkımızda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(shelter.about ?? "Bilgi yok.", style: const TextStyle(color: Colors.black87, height: 1.5)),
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
                    age: animal.breed, // Yaş yerine Cins yazalım burada
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

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}