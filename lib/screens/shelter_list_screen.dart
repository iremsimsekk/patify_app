import 'package:flutter/material.dart';
import '../services/google_places_service.dart';
import '../services/places_repository.dart';
import '../constants/ankara_districts.dart'; // <-- path sende farklıysa düzelt
import 'shelter_detail_screen.dart';

class _StarRange {
  final String label;
  final double minInclusive;
  final double maxExclusive;
  const _StarRange(this.label, this.minInclusive, this.maxExclusive);
}

class ShelterListScreen extends StatefulWidget {
  const ShelterListScreen({super.key, required this.apiKey});
  final String apiKey;

  @override
  State<ShelterListScreen> createState() => _ShelterListScreenState();
}

class _ShelterListScreenState extends State<ShelterListScreen> {
  late final GooglePlacesService _places;
  late final PlacesRepository _repo;
  late Future<List<PlaceSummary>> _future;

  String _selectedDistrict = "Tümü";
  _StarRange? _selectedStarRange;

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
    _places = GooglePlacesService(apiKey: widget.apiKey);
    _repo = PlacesRepository(places: _places, ttl: const Duration(days: 7));
    _future = _repo.getAnkaraShelters(radiusMeters: 35000);
    _selectedStarRange = _starRanges.first;
  }

  String _districtLabelOf(PlaceSummary p) {
    final addr = p.address;
    if (addr == null || addr.trim().isEmpty) return "Bilinmiyor";
    return extractAnkaraDistrict(addr) ?? "Bilinmiyor";
  }

  String _districtCityLine(PlaceSummary p) => "${_districtLabelOf(p)} / Ankara";

  bool _matchesDistrict(PlaceSummary p) {
    if (_selectedDistrict == "Tümü") return true;
    final d = _districtLabelOf(p);
    return d.toLowerCase() == _selectedDistrict.toLowerCase();
  }

  bool _matchesStars(PlaceSummary p) {
    final range = _selectedStarRange;
    if (range == null || range.label == "Tümü") return true;
    final r = (p.rating ?? 0.0);
    return r >= range.minInclusive && r < range.maxExclusive;
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        String tempDistrict = _selectedDistrict;
        _StarRange tempStarRange = _selectedStarRange ?? _starRanges.first;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Filtreler",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: tempDistrict,
                    isExpanded: true,
                    items: _districtOptions
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => tempDistrict = v ?? "Tümü"),
                    decoration: const InputDecoration(
                      labelText: "İlçe",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<_StarRange>(
                    value: tempStarRange,
                    isExpanded: true,
                    items: _starRanges
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text("Yıldız: ${r.label}"),
                            ))
                        .toList(),
                    onChanged: (v) => setModalState(
                        () => tempStarRange = v ?? _starRanges.first),
                    decoration: const InputDecoration(
                      labelText: "Yıldız Aralığı",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 14),

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
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
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
            );
          },
        );
      },
    );
  }

  Future<void> _forceRefresh() async {
    setState(() {
      _future =
          _repo.getAnkaraShelters(radiusMeters: 35000, forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ankara Barınaklar"),
        actions: [
          IconButton(
            tooltip: "Filtre",
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _openFilterSheet,
          ),
          IconButton(
            tooltip: "Yenile",
            icon: const Icon(Icons.refresh),
            onPressed: _forceRefresh,
          ),
        ],
      ),
      body: FutureBuilder<List<PlaceSummary>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Barınaklar alınamadı: ${snap.error}'),
            );
          }

          final raw = snap.data ?? [];
          final filtered = raw.where((p) {
            return _matchesDistrict(p) && _matchesStars(p);
          }).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('Filtreye uygun sonuç bulunamadı.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final shelter = filtered[index];
              final rating = shelter.rating;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white54,
                    child: Icon(Icons.store, color: Colors.teal),
                  ),
                  title: Text(
                    shelter.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Text(_districtCityLine(shelter)),
                      const SizedBox(width: 10),
                      const Text("•"),
                      const SizedBox(width: 10),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(rating != null ? rating.toStringAsFixed(1) : "-"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
    );
  }
}
