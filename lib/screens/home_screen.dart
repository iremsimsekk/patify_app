// Dosya: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'shelter_detail_screen.dart';
import 'animal_detail_screen.dart'; // Hayvan detayına gitmek için
import '../widgets/pet_card.dart';
import '../widgets/category_card.dart';
import 'veterinary_list_screen.dart'; // Yeni import

class HomeScreen extends StatefulWidget {
  final AppUser currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Filtreleme State'leri
  String _selectedType = 'Tümü'; // Tümü, Köpek, Kedi
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final shelters = mockUsers.where((u) => u.type == UserType.shelter).toList();
    
    // Filtreleme Mantığı
    final filteredAnimals = mockAnimals.where((animal) {
      final matchesType = _selectedType == 'Tümü' || animal.type == _selectedType;
      final matchesSearch = animal.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            animal.breed.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    // Renkler (Tema'dan bağımsız vurgular)
    const Color pastelPink = Color(0xFFF5D2D2);
    const Color pastelYellow = Color(0xFFF8F7BA);
    const Color pastelBlue = Color(0xFFA3CCDA);
    
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tekrar Merhaba,", style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.7))),
            Text(widget.currentUser.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_none_rounded, color: textColor), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. ARAMA ÇUBUĞU (Filtreleme Entegreli)
          TextField(
            style: TextStyle(color: textColor),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "İsim veya cins ara (örn: Golden)...",
              hintStyle: TextStyle(color: textColor.withValues(alpha: 0.6)),
              prefixIcon: Icon(Icons.search, color: textColor),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // 2. KATEGORİ FİLTRELERİ (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Tümü"),
                _buildFilterChip("Köpek"),
                _buildFilterChip("Kedi"),
                _buildFilterChip("Kuş"),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. SAHİPLENDİRME İLANLARI (Filtrelenmiş Liste)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Yuva Arayanlar (${filteredAnimals.length})",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
              ),
              TextButton(onPressed: () {}, child: const Text("Tümünü Gör", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          
          filteredAnimals.isEmpty 
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Kriterlere uygun dost bulunamadı.")))
            : SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredAnimals.length,
                itemBuilder: (context, index) {
                  final animal = filteredAnimals[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => AnimalDetailScreen(animal: animal)),
                      );
                    },
                    child: PetCard(
                      name: animal.name,
                      age: "${animal.breed}\n${animal.age}", // Cins bilgisini de gösterdik
                      imagePath: animal.imagePath,
                      backgroundColor: pastelPink,
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 24),

          // 4. HIZLI ERİŞİM (Sabit)
          Text("Hızlı Erişim", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              // GÜNCELLEME: Veteriner butonu yeni ekrana yönlendiriliyor
              CategoryCard(
                title: "Veteriner", 
                icon: Icons.local_hospital_rounded, 
                color: pastelBlue, 
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VeterinaryListScreen()));
                }
              ),
              CategoryCard(title: "Mama & Ürün", icon: Icons.fastfood_rounded, color: pastelYellow, onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),

          // 5. BARINAKLAR
          Text("Barınaklar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shelters.length,
            itemBuilder: (context, index) {
              final shelter = shelters[index];
              return Card(
                color: pastelPink,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.white54, child: Icon(Icons.store)),
                  title: Text(shelter.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(shelter.address ?? ""),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShelterDetailScreen(shelter: shelter))),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedType == label;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = label;
          });
        },
        selectedColor: theme.colorScheme.secondary, // Seçiliyken Mavi
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? theme.colorScheme.onSecondary : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}