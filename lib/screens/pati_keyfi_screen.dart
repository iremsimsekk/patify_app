import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pati_keyfi_mock_data.dart';
import '../widgets/pati_module_ui.dart';
import 'pati_keyfi_detail_screen.dart';

class PatiKeyfiScreen extends StatefulWidget {
  const PatiKeyfiScreen({super.key});

  @override
  State<PatiKeyfiScreen> createState() => _PatiKeyfiScreenState();
}

class _PatiKeyfiScreenState extends State<PatiKeyfiScreen> {
  static const String _favoritePrefsKey = 'favorite_fun_article_ids';

  String _searchQuery = '';
  String _selectedPetType = 'all';
  Set<String> _favoriteArticleIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoritePrefsKey) ?? [];

    if (!mounted) return;
    setState(() {
      _favoriteArticleIds = favoriteIds.toSet();
    });
  }

  Future<void> _toggleFavorite(String articleId) async {
    final updatedFavoriteIds = Set<String>.from(_favoriteArticleIds);

    if (updatedFavoriteIds.contains(articleId)) {
      updatedFavoriteIds.remove(articleId);
    } else {
      updatedFavoriteIds.add(articleId);
    }

    setState(() {
      _favoriteArticleIds = updatedFavoriteIds;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritePrefsKey, updatedFavoriteIds.toList());
  }

  List<FunArticle> get _filteredArticles {
    final query = _searchQuery.trim().toLowerCase();

    return mockFunArticles.where((article) {
      final matchesSearch = query.isEmpty ||
          article.title.toLowerCase().contains(query) ||
          article.summary.toLowerCase().contains(query);
      final matchesFilter =
          _selectedPetType == 'all' || article.petType == _selectedPetType;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filteredArticles = _filteredArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pati Keyfi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PatiSurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PatiIconContainer(
                  icon: Icons.celebration_rounded,
                  startColor: colorScheme.primary.withValues(alpha: 0.62),
                  endColor: colorScheme.secondary.withValues(alpha: 0.42),
                  showOverlayDot: true,
                  size: 72,
                  radius: 24,
                  iconSize: 34,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PatiBadge(
                        label: 'İçerik Seçkisi',
                        tintColor: colorScheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Daha hafif, daha keyifli',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Burada gülümseten, hafif ve keyifli içerikleri bir arada bulabilirsin. Her başlık, uygulamanın sıcak diline uyumlu kısa bir keşif alanı sunar.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.74),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _PatiSearchField(
            hintText: 'Pati Keyfi içinde ara',
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 14),
          _PetTypeFilterChips(
            selectedValue: _selectedPetType,
            onSelected: (value) {
              setState(() => _selectedPetType = value);
            },
          ),
          const SizedBox(height: 20),
          if (filteredArticles.isEmpty)
            const _EmptyResultCard(
              message: 'Aramana uygun Pati Keyfi içeriği bulunamadı.',
            )
          else
            ...filteredArticles.map(
              (article) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PatiKeyfiCard(
                  article: article,
                  isFavorite: _favoriteArticleIds.contains(article.id),
                  onFavoriteTap: () => _toggleFavorite(article.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const List<_PetTypeFilter> _petTypeFilters = [
  _PetTypeFilter(label: 'Tümü', value: 'all'),
  _PetTypeFilter(label: 'Kedi', value: 'cat'),
  _PetTypeFilter(label: 'Köpek', value: 'dog'),
  _PetTypeFilter(label: 'Genel', value: 'general'),
];

class _PetTypeFilter {
  const _PetTypeFilter({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _PatiSearchField extends StatelessWidget {
  const _PatiSearchField({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurface.withValues(alpha: 0.56),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.62),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.76),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.48),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _PetTypeFilterChips extends StatelessWidget {
  const _PetTypeFilterChips({
    required this.selectedValue,
    required this.onSelected,
  });

  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _petTypeFilters.map((filter) {
        final isSelected = selectedValue == filter.value;

        return ChoiceChip(
          label: Text(filter.label),
          selected: isSelected,
          onSelected: (_) => onSelected(filter.value),
          showCheckmark: false,
          labelStyle: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface.withValues(
              alpha: isSelected ? 0.88 : 0.68,
            ),
            fontWeight: FontWeight.w700,
          ),
          selectedColor: colorScheme.secondary.withValues(alpha: 0.3),
          backgroundColor: Colors.white.withValues(alpha: 0.58),
          side: BorderSide(
            color: isSelected
                ? colorScheme.secondary.withValues(alpha: 0.44)
                : Colors.white.withValues(alpha: 0.72),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyResultCard extends StatelessWidget {
  const _EmptyResultCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PatiSurfaceCard(
      padding: const EdgeInsets.all(18),
      radius: 24,
      color: Colors.white.withValues(alpha: 0.52),
      shadowOpacity: 0.02,
      child: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.68),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PatiKeyfiCard extends StatelessWidget {
  const _PatiKeyfiCard({
    required this.article,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final FunArticle article;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatiKeyfiDetailScreen(article: article),
            ),
          );
        },
        child: PatiSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          radius: 28,
          color: Colors.white.withValues(alpha: 0.64),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PatiIconContainer(
                icon: article.icon,
                startColor: colorScheme.primary.withValues(alpha: 0.58),
                endColor: colorScheme.secondary.withValues(alpha: 0.38),
                overlayIcon: article.moodIcon,
                size: 68,
                radius: 22,
                iconSize: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatiBadge(
                      label: 'Keyifli İçerik',
                      tintColor: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.summary,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.74),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  _FavoriteButton(
                    isFavorite: isFavorite,
                    onPressed: onFavoriteTap,
                    activeColor: colorScheme.secondary,
                  ),
                  const SizedBox(height: 8),
                  const PatiArrowChip(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
    required this.activeColor,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        onPressed: onPressed,
        tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.72),
          foregroundColor: isFavorite
              ? activeColor
              : colorScheme.onSurface.withValues(alpha: 0.56),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: BorderSide(
              color: isFavorite
                  ? activeColor.withValues(alpha: 0.28)
                  : colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
        ),
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 19,
        ),
      ),
    );
  }
}
