// Dosya: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart'; // Mock veriler
import 'shelter_detail_screen.dart'; // Barınak detayına gitmek için
import 'animal_detail_screen.dart'; // Hayvan detayına gitmek için
import '../widgets/pet_card.dart'; // Evcil hayvan kartı bileşeni
import '../widgets/category_card.dart'; // Kategori kartı bileşeni

class HomeScreen extends StatefulWidget {
  final AppUser currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Filtreleme State'leri
  String _selectedType = 'Tümü';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Mock verilerden barınakları çek
    final shelters = mockUsers.where((u) => u.type == UserType.shelter).toList();

    // --- RENK PALETİ (Görselden ve İsteğinizden) ---
    const Color pastelGreen = Color(0xFFBDE3C3); // Arka Plan
    const Color pastelPink = Color(0xFFF5D2D2);  // Kartlar (Widgetlar)
    const Color pastelYellow = Color(0xFFF8F7BA); // Hızlı Erişim 1
    const Color pastelBlue = Color(0xFFA3CCDA);   // Hızlı Erişim 2
    
    // Yazı Renkleri (Koyu Tonlar)
    const Color darkTextPrimary = Color(0xFF1B4242); // Koyu Yeşilimsi (Ana Metin)
    const Color darkTextSecondary = Color(0xFF3A0519); // Koyu Bordo (Başlıklar)

    // Filtreleme Mantığı
    final filteredAnimals = mockAnimals.where((animal) {
      final matchesType = _selectedType == 'Tümü' || animal.type == _selectedType;
      final matchesSearch = animal.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            animal.breed.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: pastelGreen, // Arka planı zorla Pastel Yeşil yapıyoruz
      appBar: AppBar(
        backgroundColor: pastelGreen, // AppBar da yeşil
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tekrar Merhaba,",
              style: TextStyle(fontSize: 14, color: darkTextPrimary),
            ),
            Text(
              widget.currentUser.name, 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: darkTextPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. ARAMA ÇUBUĞU
          TextField(
            style: const TextStyle(color: darkTextPrimary),
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: "İsim veya cins ara...",
              hintStyle: TextStyle(color: darkTextPrimary.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.search, color: darkTextPrimary),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.6), // Hafif transparan beyaz
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // 2. KATEGORİ FİLTRELERİ (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Tümü", darkTextPrimary, darkTextSecondary),
                _buildFilterChip("Köpek", darkTextPrimary, darkTextSecondary),
                _buildFilterChip("Kedi", darkTextPrimary, darkTextSecondary),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. HIZLI ERİŞİM (Mavi ve Sarı)
          Text(
            "Hızlı Erişim",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextSecondary),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              CategoryCard(
                title: "Veteriner",
                icon: Icons.local_hospital_rounded,
                color: pastelBlue, // Mavi
                onTap: () {},
              ),
              CategoryCard(
                title: "Mama & Ürün",
                icon: Icons.fastfood_rounded,
                color: pastelYellow, // Sarı
                onTap: () {},
              ),
              CategoryCard(
                title: "Yürüyüş",
                icon: Icons.directions_walk_rounded,
                color: pastelBlue, // Mavi
                onTap: () {},
              ),
              CategoryCard(
                title: "Eğitim",
                icon: Icons.sports_baseball_rounded,
                color: pastelYellow, // Sarı
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. YUVA ARAYANLAR (Pet Cards) - PASTEL PEMBE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Yuva Arayanlar (${filteredAnimals.length})",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextSecondary),
              ),
              TextButton(
                onPressed: () {}, 
                child: Text("Tümünü Gör", style: TextStyle(fontWeight: FontWeight.bold, color: darkTextPrimary))
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          filteredAnimals.isEmpty 
            ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Sonuç bulunamadı.", style: TextStyle(color: darkTextPrimary))))
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
                      age: "${animal.breed}\n${animal.age}",
                      imagePath: animal.imagePath,
                      backgroundColor: pastelPink, // İstenilen Pembe Renk
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),

          // 5. ANLAŞMALI BARINAKLAR - KARTLAR PASTEL PEMBE
          Text(
            "Barınaklar",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextSecondary),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shelters.length,
            itemBuilder: (context, index) {
              final shelter = shelters[index];
              return Card(
                color: pastelPink, // İstenilen Pembe Renk
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white54, 
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.store, color: darkTextPrimary),
                  ),
                  title: Text(
                    shelter.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkTextSecondary),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: darkTextPrimary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(shelter.address ?? "Adres Yok", style: TextStyle(color: darkTextPrimary), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: darkTextPrimary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShelterDetailScreen(shelter: shelter),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget _buildFilterChip(String label, Color textColor, Color selectedColor) {
    final isSelected = _selectedType == label;
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
        // Seçiliyken Koyu Bordo, değilken Beyaz
        selectedColor: selectedColor.withValues(alpha: 0.2), 
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? selectedColor : textColor,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}