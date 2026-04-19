import 'package:flutter/material.dart';

import '../data/guide_mock_data.dart';
import '../widgets/pati_module_ui.dart';
import 'rehber_detail_screen.dart';

class RehberScreen extends StatefulWidget {
  const RehberScreen({super.key});

  @override
  State<RehberScreen> createState() => _RehberScreenState();
}

class _RehberScreenState extends State<RehberScreen> {
  String _searchQuery = '';
  String _selectedPetType = 'all';

  List<GuideArticle> get _filteredArticles {
    final query = _searchQuery.trim().toLowerCase();

    return mockGuideArticles.where((article) {
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
        title: const Text('Rehber'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PatiSurfaceCard(
            padding: const EdgeInsets.all(20),
            radius: 24,
            color: Colors.white.withValues(alpha: 0.45),
            borderOpacity: 0,
            shadowOpacity: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kısa ve faydalı bilgiler',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Patili dostunun bakımı, günlük rutini ve dikkat etmen gereken temel konulara dair içerikleri burada bulabilirsin.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _PatiSearchField(
            hintText: 'Rehberde ara',
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
              message: 'Aramana uygun rehber içeriği bulunamadı.',
            )
          else
            ...filteredArticles.map(
              (article) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _GuideListCard(article: article),
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
          selectedColor: colorScheme.primary.withValues(alpha: 0.32),
          backgroundColor: Colors.white.withValues(alpha: 0.58),
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.46)
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

class _GuideListCard extends StatelessWidget {
  const _GuideListCard({required this.article});

  final GuideArticle article;

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
              builder: (_) => RehberDetailScreen(article: article),
            ),
          );
        },
        child: PatiSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          radius: 28,
          color: Colors.white.withValues(alpha: 0.66),
          shadowOpacity: 0.05,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PatiIconContainer(
                icon: article.icon,
                startColor: colorScheme.primary.withValues(alpha: 0.62),
                endColor: colorScheme.secondary.withValues(alpha: 0.42),
                showOverlayDot: true,
                size: 68,
                radius: 22,
                iconSize: 31,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatiBadge(
                      label: 'Bakım Rehberi',
                      tintColor: colorScheme.secondary,
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
              const SizedBox(width: 12),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: PatiArrowChip(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
