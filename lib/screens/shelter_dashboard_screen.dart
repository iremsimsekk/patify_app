// Dosya: lib/screens/shelter_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/pet_card.dart';
import 'add_animal_screen.dart';
import 'shelter_profile_screen.dart';
import 'animal_detail_screen.dart';

class ShelterDashboardScreen extends StatefulWidget {
  final AppUser shelterUser;

  const ShelterDashboardScreen({super.key, required this.shelterUser});

  @override
  State<ShelterDashboardScreen> createState() => _ShelterDashboardScreenState();
}

class _ShelterDashboardScreenState extends State<ShelterDashboardScreen> {
  int _currentIndex = 0; 

  void _refreshList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final myAnimals = getAnimalsByShelter(widget.shelterUser.id);
    final theme = Theme.of(context);

    final dashboardContent = Scaffold(
      appBar: AppBar(
        title: Text(widget.shelterUser.name, style: const TextStyle(fontSize: 18)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // İstatistikler (Aynı Kalıyor)
          Row(
            children: [
              Expanded(
                child: _buildStatCard("${myAnimals.length}", "Sahiplendirme\nBekleyen", Colors.orangeAccent, Icons.pets),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard("12", "Başarıyla\nYuvalanan", Colors.green, Icons.home_filled),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("İlanlarınız", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddAnimalScreen(shelterUser: widget.shelterUser)),
                  );
                  if (result == true) _refreshList();
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Yeni İlan"),
              ),
            ],
          ),
          const SizedBox(height: 12),

          myAnimals.isEmpty 
            ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("Henüz ilanınız yok.")))
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: myAnimals.length,
                itemBuilder: (context, index) {
                  final animal = myAnimals[index];
                  return GestureDetector(
                    // GÜNCELLEME: Detay sayfasına "isOwner: true" ile git ve dönüşte yenile
                    onTap: () async {
                      final result = await Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => AnimalDetailScreen(
                            animal: animal, 
                            isOwner: true, // Barınak sahibi kendi ilanına bakıyor
                          )
                        )
                      );
                      // Eğer detay sayfasından silme/güncelleme işlemi yapılıp dönüldüyse listeyi yenile
                      if (result == true) {
                        _refreshList();
                      }
                    },
                    child: Stack(
                      children: [
                        PetCard(
                          name: animal.name,
                          age: animal.breed,
                          imagePath: animal.imagePath,
                          backgroundColor: theme.cardTheme.color ?? Colors.white,
                        ),
                        // Düzenle ikonu dekoratif olarak kalabilir, işlevi detay sayfasında
                        Positioned(
                          right: 12,
                          top: 8,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit, size: 16, color: Colors.grey[400]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddAnimalScreen(shelterUser: widget.shelterUser)),
          );
          if (result == true) _refreshList();
        },
        label: const Text("İlan Ekle"),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
      ),
    );

    final profileContent = ShelterProfileScreen(shelterUser: widget.shelterUser);

    return Scaffold(
      body: _currentIndex == 0 ? dashboardContent : profileContent,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: "Panel"),
          NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String count, String label, Color color, IconData icon) {
    // (Bu kısım aynı kalıyor, yukarıdaki kodun devamı...)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, height: 1.2, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}