import 'package:flutter/material.dart';
import 'package:patify_app/screens/ai_chat_screen.dart';

import '../data/mock_data.dart';
import '../services/google_places_service.dart';
import '../widgets/category_card.dart';
import '../widgets/pet_card.dart';
import 'animal_detail_screen.dart';
import 'shelter_detail_screen.dart';
import 'shelter_list_screen.dart';
import 'veterinary_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.currentUser,
    required this.apiKey,
  });

  final AppUser currentUser;
  final String apiKey;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedType = 'Tumu';
  String _searchQuery = '';

  late final GooglePlacesService _places;
  Future<List<PlaceSummary>>? _sheltersFuture;

  bool get _isGuest => widget.currentUser.isGuest;

  @override
  void initState() {
    super.initState();
    _places = GooglePlacesService(apiKey: widget.apiKey);
    if (!_isGuest) {
      _sheltersFuture = _places.fetchAnkaraShelters(radiusMeters: 35000);
    }
  }

  String _districtCity(String? address) {
    if (address == null || address.trim().isEmpty) return 'Bilinmiyor / Ankara';
    final value = address.trim();

    final slash = RegExp(r'([^,/]+)\s*/\s*([^,]+)').firstMatch(value);
    if (slash != null) {
      final district = slash.group(1)!.trim();
      final city = slash.group(2)!.trim();
      return '$district / $city';
    }

    final parts = value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      final city = parts.last;
      final district = parts[parts.length - 2];
      return '$district / $city';
    }

    return '$value / Ankara';
  }

  void _showGuestNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Misafir modunda harita ve kurum listeleri kapali. Bu alanlar icin giris yapman gerekiyor.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color pastelGreen = Color(0xFFBDE3C3);
    const Color pastelPink = Color(0xFFF5D2D2);
    const Color pastelYellow = Color(0xFFF8F7BA);
    const Color pastelBlue = Color(0xFFA3CCDA);

    const Color darkTextPrimary = Color(0xFF1B4242);
    const Color darkTextSecondary = Color(0xFF3A0519);

    final filteredAnimals = mockAnimals.where((animal) {
      final matchesType =
          _selectedType == 'Tumu' || animal.type == _selectedType;
      final matchesSearch =
          animal.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              animal.breed.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: pastelGreen,
      appBar: AppBar(
        backgroundColor: pastelGreen,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tekrar Merhaba,',
              style: TextStyle(fontSize: 14, color: darkTextPrimary),
            ),
            Text(
              widget.currentUser.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: darkTextPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_isGuest)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Misafir modunda temel icerigi gezebilirsin. Harita ve kurum listeleri icin giris yapman gerekiyor.',
                style: TextStyle(
                  color: darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextField(
            style: const TextStyle(color: darkTextPrimary),
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Isim veya cins ara...',
              hintStyle: TextStyle(
                color: darkTextPrimary.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.search, color: darkTextPrimary),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tumu', darkTextPrimary, darkTextSecondary),
                _buildFilterChip('Kopek', darkTextPrimary, darkTextSecondary),
                _buildFilterChip('Kedi', darkTextPrimary, darkTextSecondary),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Hizli Erisim',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkTextSecondary,
            ),
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
                title: 'Veteriner',
                icon: Icons.local_hospital_rounded,
                color: pastelBlue,
                onTap: () {
                  if (_isGuest) {
                    _showGuestNotice();
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VeterinaryListScreen(apiKey: widget.apiKey),
                    ),
                  );
                },
              ),
              CategoryCard(
                title: 'Barinaklar',
                icon: Icons.store,
                color: pastelYellow,
                onTap: () {
                  if (_isGuest) {
                    _showGuestNotice();
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShelterListScreen(apiKey: widget.apiKey),
                    ),
                  );
                },
              ),
              CategoryCard(
                title: 'Yuruyus',
                icon: Icons.directions_walk_rounded,
                color: pastelBlue,
                onTap: () {},
              ),
              CategoryCard(
                title: 'Egitim',
                icon: Icons.sports_baseball_rounded,
                color: pastelYellow,
                onTap: () {},
              ),
              CategoryCard(
                title: 'AI Asistan',
                icon: Icons.smart_toy_rounded,
                color: pastelPink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AiChatScreen(),
                    ),
                  );
                },
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yuva Arayanlar (${filteredAnimals.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkTextSecondary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Tumunu Gor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          filteredAnimals.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Sonuc bulunamadi.',
                      style: TextStyle(color: darkTextPrimary),
                    ),
                  ),
                )
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
                            MaterialPageRoute(
                              builder: (_) =>
                                  AnimalDetailScreen(animal: animal),
                            ),
                          );
                        },
                        child: PetCard(
                          name: animal.name,
                          age: '${animal.breed}\n${animal.age}',
                          imagePath: animal.imagePath,
                          backgroundColor: pastelPink,
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Barinaklar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkTextSecondary,
                ),
              ),
              TextButton(
                onPressed: _isGuest
                    ? _showGuestNotice
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ShelterListScreen(apiKey: widget.apiKey),
                          ),
                        );
                      },
                child: const Text(
                  'Tumunu Gor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isGuest)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Barinak listesi misafir modunda gizlenir.',
                style: TextStyle(color: darkTextPrimary),
              ),
            )
          else if (_sheltersFuture != null)
            FutureBuilder<List<PlaceSummary>>(
              future: _sheltersFuture,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Barinaklar yuklenemedi: ${snap.error}',
                      style: const TextStyle(color: darkTextPrimary),
                    ),
                  );
                }

                final shelters = snap.data ?? <PlaceSummary>[];
                final preview = shelters.take(6).toList();

                if (preview.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Barinak bulunamadi.',
                      style: TextStyle(color: darkTextPrimary),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: preview.length,
                  itemBuilder: (context, index) {
                    final shelter = preview[index];
                    return Card(
                      color: pastelPink,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white54,
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Icon(Icons.store, color: darkTextPrimary),
                        ),
                        title: Text(
                          shelter.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: darkTextSecondary,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: darkTextPrimary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _districtCity(shelter.address),
                                style: const TextStyle(color: darkTextPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: darkTextPrimary,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShelterDetailScreen(
                                apiKey: widget.apiKey,
                                placeId: shelter.placeId,
                                title: shelter.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
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
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedType = label),
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
