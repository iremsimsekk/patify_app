import 'package:flutter/material.dart';

import '../constants/ankara_districts.dart';
import '../services/google_places_service.dart';
import '../services/institution_repository.dart';
import '../theme/patify_theme.dart';
import '../widgets/patify_user_bottom_nav.dart';
import '../widgets/place_directory_widgets.dart';
import 'veterinary_detail_screen.dart';

class _StarRange {
  final String label;
  final double minInclusive;
  final double maxExclusive;

  const _StarRange(this.label, this.minInclusive, this.maxExclusive);
}

class VeterinaryListScreen extends StatefulWidget {
  const VeterinaryListScreen({super.key, required this.apiKey});

  final String apiKey;

  @override
  State<VeterinaryListScreen> createState() => _VeterinaryListScreenState();
}

class _VeterinaryListScreenState extends State<VeterinaryListScreen> {
  late final InstitutionRepository _repo;
  late Future<List<PlaceSummary>> _future;
  late final TextEditingController _searchController;

  String _searchQuery = '';
  String _selectedDistrict = "Tümü";
  _StarRange? _selectedStarRange;
  bool _isRefreshing = false;

  List<String> get _districtOptions => ["Tümü", ...ankaraDistricts];

  static const List<_StarRange> _starRanges = [
    _StarRange("Tümü", -1, 999999),
    _StarRange("0 - 1", 0, 1),
    _StarRange("1 - 2", 1, 2),
    _StarRange("2 - 3", 2, 3),
    _StarRange("3 - 4", 3, 4),
    _StarRange("4 - 5", 4, 5.000001),
  ];

  @override
  void initState() {
    super.initState();
    _repo = InstitutionRepository();
    _future = _repo.getAnkaraVets(radiusMeters: 35000);
    _selectedStarRange = _starRanges.first;
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _districtLabelOf(PlaceSummary place) {
    final address = place.address;
    if (address == null || address.trim().isEmpty) return "Konum bilinmiyor";
    return extractAnkaraDistrict(address) ?? "Konum bilinmiyor";
  }

  String _districtCityLine(PlaceSummary place) {
    final district = _districtLabelOf(place);
    if (district == "Konum bilinmiyor") return district;
    return "$district / Ankara";
  }

  bool _matchesDistrict(PlaceSummary place) {
    if (_selectedDistrict == "Tümü") return true;
    final district = _districtLabelOf(place);
    return district.toLowerCase() == _selectedDistrict.toLowerCase();
  }

  bool _matchesStars(PlaceSummary place) {
    final range = _selectedStarRange;
    if (range == null || range.label == "Tümü") return true;

    final rating = place.rating ?? 0.0;
    return rating >= range.minInclusive && rating < range.maxExclusive;
  }

  bool _matchesSearch(PlaceSummary place) {
    final query = _normalize(_searchQuery);
    if (query.isEmpty) return true;

    final haystack = _normalize([
      place.name,
      place.address ?? '',
      _districtLabelOf(place),
      place.email ?? '',
      place.phone ?? '',
      place.website ?? '',
    ].join(' '));

    return haystack.contains(query);
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .trim();
  }

  String get _selectedRatingLabel =>
      _selectedStarRange == null || _selectedStarRange!.label == "Tümü"
          ? "Tüm puanlar"
          : "${_selectedStarRange!.label} yıldız";

  Future<void> _forceRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _future = _repo.getAnkaraVets(radiusMeters: 35000, forceRefresh: true);
    });

    try {
      final result = await _future;
      if (!mounted) return;
      RefreshFeedback.show(
        context,
        message: '${result.length} veteriner kliniği güncellendi.',
        success: true,
      );
    } catch (_) {
      if (!mounted) return;
      RefreshFeedback.show(
        context,
        message: 'Liste yenilenirken bir sorun oluştu.',
        success: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        String tempDistrict = _selectedDistrict;
        _StarRange tempStarRange = _selectedStarRange ?? _starRanges.first;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  decoration: const BoxDecoration(
                    color: PatifyTheme.surfaceRaised,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(PatifyTheme.radius24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PatifyTheme.space20,
                      PatifyTheme.space8,
                      PatifyTheme.space20,
                      PatifyTheme.space20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Filtreleri düzenle",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: PatifyTheme.space20),
                        DropdownButtonFormField<String>(
                          initialValue: tempDistrict,
                          isExpanded: true,
                          items: _districtOptions
                              .map(
                                (district) => DropdownMenuItem(
                                  value: district,
                                  child: Text(district),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setModalState(() => tempDistrict = value ?? "Tümü");
                          },
                          decoration: const InputDecoration(
                            labelText: "İlçe",
                          ),
                        ),
                        const SizedBox(height: PatifyTheme.space12),
                        DropdownButtonFormField<_StarRange>(
                          initialValue: tempStarRange,
                          isExpanded: true,
                          items: _starRanges
                              .map(
                                (range) => DropdownMenuItem(
                                  value: range,
                                  child: Text("Puan: ${range.label}"),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setModalState(
                              () => tempStarRange = value ?? _starRanges.first,
                            );
                          },
                          decoration: const InputDecoration(
                            labelText: "Puan aralığı",
                          ),
                        ),
                        const SizedBox(height: PatifyTheme.space20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedDistrict = "Tümü";
                                    _selectedStarRange = _starRanges.first;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Temizle"),
                              ),
                            ),
                            const SizedBox(width: PatifyTheme.space12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedDistrict = tempDistrict;
                                    _selectedStarRange = tempStarRange;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Uygula"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Veteriner Klinikleri"),
      ),
      bottomNavigationBar: const PatifyUserBottomNav(
        current: PatifyUserNavItem.services,
      ),
      body: FutureBuilder<List<PlaceSummary>>(
        future: _future,
        builder: (context, snapshot) {
          late final Widget content;
          late final String stateKey;

          if (snapshot.connectionState != ConnectionState.done) {
            content = const DirectoryLoadingView(
              label: "Ankara'daki veteriner klinikleri senin için yükleniyor.",
            );
            stateKey = 'loading';
          } else if (snapshot.hasError) {
            content = DirectoryStateCard(
              icon: Icons.error_outline_rounded,
              title: "Liste yüklenemedi",
              message:
                  "Veteriner klinikleri alınırken bir sorun oluştu. Lütfen tekrar dene.\n\n${snapshot.error}",
              actionLabel: "Tekrar dene",
              onAction: _forceRefresh,
            );
            stateKey = 'error';
          } else {
            final raw = snapshot.data ?? [];
            final filtered = raw.where((place) {
              return _matchesDistrict(place) &&
                  _matchesStars(place) &&
                  _matchesSearch(place);
            }).toList();

            if (filtered.isEmpty) {
              content = DirectoryStateCard(
                icon: Icons.search_off_rounded,
                title: "Sonuç bulunamadı",
                message: _searchQuery.trim().isNotEmpty
                    ? "Aramanıza uygun veteriner bulunamadı."
                    : "Seçtiğin filtrelere uygun veteriner kliniği bulunamadı. Filtreleri değiştirip yeniden deneyebilirsin.",
                actionLabel: "Filtreleri düzenle",
                onAction: _openFilterSheet,
              );
              stateKey = 'empty';
            } else {
              content = RefreshIndicator(
                onRefresh: _forceRefresh,
                color: PatifyTheme.primary,
                backgroundColor: PatifyTheme.surfaceRaised,
                edgeOffset: 12,
                displacement: 24,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    PatifyTheme.space20,
                    PatifyTheme.space12,
                    PatifyTheme.space20,
                    PatifyTheme.space28,
                  ),
                  children: [
                    DirectoryHero(
                      icon: Icons.local_hospital_rounded,
                      title: "Ankara'daki veterinerler",
                      subtitle: "Veteriner klinikleri",
                      resultCount: filtered.length,
                      primaryActionLabel: "Filtrele",
                      onPrimaryAction: _openFilterSheet,
                      secondaryActionLabel: "Yenile",
                      onSecondaryAction: _forceRefresh,
                      isRefreshing: _isRefreshing,
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    DirectoryFilterRow(
                      districtLabel: _selectedDistrict == "Tümü"
                          ? "Tüm ilçeler"
                          : _selectedDistrict,
                      ratingLabel: _searchQuery.trim().isEmpty
                          ? _selectedRatingLabel
                          : 'Arama: $_searchQuery',
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Veteriner adı, adres veya ilçe ara',
                        prefixIcon: Icon(Icons.search_rounded),
                        suffixIcon: Icon(Icons.tune_rounded),
                      ),
                    ),
                    const SizedBox(height: PatifyTheme.space20),
                    Text(
                      "Öne çıkan sonuçlar",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    ...filtered.asMap().entries.map((entry) {
                      final index = entry.key;
                      final clinic = entry.value;

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: PatifyTheme.space12),
                        child: PlaceResultCard(
                          place: clinic,
                          index: index,
                          categoryLabel: "Veteriner kliniği",
                          locationLabel: _districtCityLine(clinic),
                          icon: Icons.local_hospital_rounded,
                          iconColor: PatifyTheme.info,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VeterinaryDetailScreen(
                                  apiKey: widget.apiKey,
                                  placeId: clinic.placeId,
                                  title: clinic.name,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
              stateKey =
                  'list_${filtered.length}_${_selectedDistrict}_$_selectedRatingLabel';
            }
          }

          return DirectoryStateSwitcher(
            stateKey: stateKey,
            child: content,
          );
        },
      ),
    );
  }
}
