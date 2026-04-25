import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/google_places_service.dart';
import '../services/institution_api_service.dart';
import '../theme/patify_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/pet_card.dart';
import 'ai_chat_screen.dart';
import 'animal_detail_screen.dart';
import 'map_screen.dart';
import 'pet_care_screen.dart';
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
  String _selectedType = 'Tümü';
  String _searchQuery = '';

  Future<List<PlaceSummary>>? _sheltersFuture;

  bool get _isGuest => widget.currentUser.isGuest;

  @override
  void initState() {
    super.initState();
    if (!_isGuest) {
      _sheltersFuture = InstitutionApiService.fetchShelters();
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
          'Misafir modunda kurum listeleri ve harita kapalıdır. Bu alanları görmek için giriş yapman gerekir.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredAnimals = mockAnimals.where((animal) {
      final matchesType =
          _selectedType == 'Tümü' || animal.type == _selectedType;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = animal.name.toLowerCase().contains(query) ||
          animal.breed.toLowerCase().contains(query);
      return matchesType && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patify'),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Bildirimler',
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PatifyTheme.space20,
          PatifyTheme.space12,
          PatifyTheme.space20,
          120,
        ),
        children: [
          _DashboardIntro(
            name: widget.currentUser.name,
            isGuest: _isGuest,
            onAiTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiChatScreen()),
              );
            },
          ),
          const SizedBox(height: PatifyTheme.space24),
          _SectionHeader(
            eyebrow: 'Hızlı erişim',
            title: 'Temel hizmetler',
            actionLabel: 'Hizmetlere git',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PetCareScreen(apiKey: widget.apiKey),
                ),
              );
            },
          ),
          const SizedBox(height: PatifyTheme.space12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.08,
            crossAxisSpacing: PatifyTheme.space16,
            mainAxisSpacing: PatifyTheme.space16,
            children: [
              CategoryCard(
                title: 'Veteriner klinikleri',
                icon: Icons.local_hospital_rounded,
                color: PatifyTheme.info,
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
                title: 'Barınaklar',
                icon: Icons.home_work_rounded,
                color: PatifyTheme.accent,
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
                title: 'Harita',
                icon: Icons.map_outlined,
                color: PatifyTheme.secondary,
                onTap: () {
                  if (_isGuest) {
                    _showGuestNotice();
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapScreen(apiKey: widget.apiKey),
                    ),
                  );
                },
              ),
              CategoryCard(
                title: 'AI desteği',
                icon: Icons.auto_awesome_rounded,
                color: PatifyTheme.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiChatScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: PatifyTheme.space28),
          const _SectionHeader(
            eyebrow: 'Sahiplendirme',
            title: 'Yuva arayan dostlar',
          ),
          const SizedBox(height: PatifyTheme.space12),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              hintText: 'İsim veya cins ara',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: PatifyTheme.space12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tümü'),
                _buildFilterChip('Köpek'),
                _buildFilterChip('Kedi'),
              ],
            ),
          ),
          const SizedBox(height: PatifyTheme.space16),
          SizedBox(
            height: 228,
            child: filteredAnimals.isEmpty
                ? const _EmptyPanel(
                    title: 'Sonuç bulunamadı',
                    subtitle:
                        'Arama terimini veya filtreleri güncelleyerek yeniden deneyebilirsin.',
                  )
                : ListView.builder(
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
                          backgroundColor: theme.cardColor,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: PatifyTheme.space28),
          _SectionHeader(
            eyebrow: 'Yakındaki noktalar',
            title: 'Barınaklar',
            actionLabel: 'Listeyi aç',
            onAction: _isGuest
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
          ),
          const SizedBox(height: PatifyTheme.space12),
          if (_isGuest)
            const _EmptyPanel(
              title: 'Barınak listesi kapalı',
              subtitle: 'Bu bölüm misafir modunda gösterilmez.',
            )
          else if (_sheltersFuture != null)
            FutureBuilder<List<PlaceSummary>>(
              future: _sheltersFuture,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const _LoadingListPanel();
                }
                if (snap.hasError) {
                  return const _EmptyPanel(
                    title: 'Barınaklar yüklenemedi',
                    subtitle: 'Lütfen kısa süre sonra tekrar dene.',
                    icon: Icons.error_outline_rounded,
                    color: PatifyTheme.danger,
                  );
                }

                final shelters = snap.data ?? <PlaceSummary>[];
                final preview = shelters.take(4).toList();

                if (preview.isEmpty) {
                  return const _EmptyPanel(
                    title: 'Barınak bulunamadı',
                    subtitle: 'Şu anda gösterilecek kurum bulunmuyor.',
                  );
                }

                return Column(
                  children: preview
                      .map(
                        (shelter) => Card(
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.all(PatifyTheme.space16),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: PatifyTheme.primarySoft,
                                borderRadius:
                                    BorderRadius.circular(PatifyTheme.radius16),
                              ),
                              child: const Icon(
                                Icons.home_work_rounded,
                                color: PatifyTheme.primary,
                              ),
                            ),
                            title: Text(shelter.name),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(
                                  top: PatifyTheme.space4),
                              child: Text(
                                _districtCity(shelter.address),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: PatifyTheme.textSecondary,
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
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value) {
    final isSelected = _selectedType == value;
    return Padding(
      padding: const EdgeInsets.only(right: PatifyTheme.space8),
      child: ChoiceChip(
        label: Text(value),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedType = value),
        showCheckmark: false,
      ),
    );
  }
}

class _DashboardIntro extends StatelessWidget {
  const _DashboardIntro({
    required this.name,
    required this.isGuest,
    required this.onAiTap,
  });

  final String name;
  final bool isGuest;
  final VoidCallback onAiTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(PatifyTheme.radius24),
        border: Border.all(color: PatifyTheme.border),
        boxShadow: [
          BoxShadow(
            color: PatifyTheme.textPrimary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugün',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: PatifyTheme.space4),
                    Text(
                      name,
                      style: theme.textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PatifyTheme.primarySoft,
                  borderRadius: BorderRadius.circular(PatifyTheme.radius16),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: PatifyTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PatifyTheme.space16),
          Text(
            isGuest
                ? 'Temel içerikleri inceleyebilir, kurum listeleri için giriş yapabilirsin.'
                : 'Yakındaki hizmetlere, sahiplendirme ilanlarına ve akıllı desteğe tek yerden ulaş.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: PatifyTheme.space16),
          Row(
            children: [
              const Expanded(
                child: _MetricTile(
                  label: 'Hizmetler',
                  value: '6+',
                  tone: PatifyTheme.secondary,
                ),
              ),
              const SizedBox(width: PatifyTheme.space12),
              Expanded(
                child: _MetricTile(
                  label: 'Sahiplendirme',
                  value: '${mockAnimals.length}',
                  tone: PatifyTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: PatifyTheme.space16),
          OutlinedButton.icon(
            onPressed: onAiTap,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('AI desteğini aç'),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space16),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PatifyTheme.radius20),
        border: Border.all(color: tone.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            value,
            style: theme.textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String eyebrow;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.color = PatifyTheme.textSecondary,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(PatifyTheme.radius20),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(PatifyTheme.radius16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: PatifyTheme.space12),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingListPanel extends StatelessWidget {
  const _LoadingListPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(PatifyTheme.space16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: PatifyTheme.primarySoft,
                    borderRadius: BorderRadius.circular(PatifyTheme.radius16),
                  ),
                ),
                const SizedBox(width: PatifyTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: PatifyTheme.divider,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: PatifyTheme.space8),
                      FractionallySizedBox(
                        widthFactor: 0.65,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: PatifyTheme.divider,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
