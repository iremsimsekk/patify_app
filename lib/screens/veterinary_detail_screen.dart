// Dosya: lib/screens/veterinary_detail_screen.dart (GÜNCELLENDİ - Google Places ile)
import 'package:flutter/material.dart';
import '../services/google_places_service.dart';

class VeterinaryDetailScreen extends StatefulWidget {
  final String apiKey;
  final String placeId;
  final String title; // AppBar için (liste ekranından gönder)

  const VeterinaryDetailScreen({
    super.key,
    required this.apiKey,
    required this.placeId,
    required this.title,
  });

  @override
  State<VeterinaryDetailScreen> createState() => _VeterinaryDetailScreenState();
}

class _VeterinaryDetailScreenState extends State<VeterinaryDetailScreen> {
  late final GooglePlacesService _places;
  late final Future<PlaceDetails> _detailsFuture;

  // Mock müsait zaman dilimleri (aynı kalıyor)
  final Map<String, List<String>> _availableSlots = {
    "Pazartesi, 24/11": ["10:00", "11:00", "14:00", "15:00"],
    "Salı, 25/11": ["09:30", "11:30", "13:30", "16:00"],
    "Çarşamba, 26/11": ["10:00", "15:00", "16:30"],
  };

  final List<String> _appointmentTypes = [
    "Genel Muayene",
    "Aşı Kontrolü",
    "Tırnak Kesimi",
    "Acil Durum (Ön Bilgilendirme)",
  ];

  // State değişkenleri
  String? _selectedDate;
  String? _selectedTime;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _places = GooglePlacesService(apiKey: widget.apiKey);
    _detailsFuture = _places.fetchDetails(widget.placeId);
  }

  void _sendAppointmentRequest(String clinicName) {
    if (_selectedDate == null || _selectedTime == null || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir gün, saat ve randevu tipi seçiniz.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Randevu Başvurusu Alındı ❤️"),
        content: Text(
          "Talebiniz başarıyla iletildi:\n\n"
          "Klinik: $clinicName\n"
          "Tarih/Saat: $_selectedDate, $_selectedTime\n"
          "Hizmet: $_selectedType",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedDate = null;
                _selectedTime = null;
                _selectedType = null;
              });
            },
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  String _workingHoursText(PlaceDetails d) {
    if (d.weekdayText == null || d.weekdayText!.isEmpty) return "Çalışma saatleri: Bilinmiyor";
    // Çok uzun olmasın diye tek satırda birleştiriyoruz (istersen alt alta da yaparız)
    return d.weekdayText!.join(" | ");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTimes = _selectedDate != null ? _availableSlots[_selectedDate!]! : <String>[];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<PlaceDetails>(
        future: _detailsFuture,
        builder: (context, snap) {
          // Detay yüklenirken bile randevu UI’ı kalsın diye tek builder içinde devam ediyoruz
          final isLoading = snap.connectionState != ConnectionState.done;
          final hasError = snap.hasError;
          final details = snap.data;

          final clinicName = details?.name ?? widget.title;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Klinik Bilgileri (Google’dan)
                Card(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Builder(
                      builder: (_) {
                        if (isLoading) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Bilgiler yükleniyor...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              LinearProgressIndicator(),
                            ],
                          );
                        }

                        if (hasError || details == null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(clinicName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text("Detay alınamadı: ${snap.error}"),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(details.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.location_on_outlined, details.formattedAddress ?? "Adres: Bilinmiyor"),
                            _buildInfoRow(Icons.phone_outlined, details.phone ?? "Telefon: Bilinmiyor"),
                            _buildInfoRow(Icons.access_time_outlined, _workingHoursText(details)),
                            if (details.website != null) _buildInfoRow(Icons.language, details.website!),
                            if (details.rating != null)
                              _buildInfoRow(
                                Icons.star_outline,
                                "Puan: ${details.rating} (${details.userRatingsTotal ?? 0} oy)",
                              ),
                            const Divider(height: 24),
                            Text(
                              "Hakkımızda:",
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                            const Text(
                              "Bu işletme bilgileri Google Places üzerinden alınır. Bazı alanlar işletmeye göre eksik olabilir.",
                              style: TextStyle(height: 1.5),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 1. Randevu Tipi Seçimi (Aynı)
                Text(
                  "1. Randevu Tipini Seçiniz",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(border: InputBorder.none, hintText: "Hizmet Seçiniz"),
                    initialValue: _selectedType,
                    items: _appointmentTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // 2. Müsait Gün Seçimi (Aynı)
                Text(
                  "2. Müsait Günü Seçiniz",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableSlots.keys.map((date) {
                      final isSelected = _selectedDate == date;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(date),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDate = date;
                                _selectedTime = null;
                              } else {
                                _selectedDate = null;
                                _selectedTime = null;
                              }
                            });
                          },
                          selectedColor: theme.colorScheme.secondary,
                          backgroundColor: theme.cardTheme.color,
                          labelStyle: TextStyle(
                            color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 30),

                // 3. Müsait Saat Seçimi (Aynı)
                Text(
                  "3. Müsait Saati Seçiniz",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 12),

                if (_selectedDate == null)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Lütfen yukarıdan bir gün seçiniz.", style: TextStyle(color: Colors.grey)),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: currentTimes.length,
                    itemBuilder: (context, index) {
                      final time = currentTimes[index];
                      final isSelected = _selectedTime == time;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.secondary : theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.onSecondary : Colors.transparent,
                              width: isSelected ? 2 : 0,
                            ),
                          ),
                          child: Text(
                            time,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 40),

                // Randevu Al Butonu (Aynı)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: (_selectedDate != null && _selectedTime != null && _selectedType != null)
                        ? () => _sendAppointmentRequest(clinicName)
                        : null,
                    icon: const Icon(Icons.add_task),
                    label: const Text("Randevu Talebi Gönder"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_selectedDate != null && _selectedTime != null && _selectedType != null)
                          ? theme.colorScheme.secondary
                          : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
