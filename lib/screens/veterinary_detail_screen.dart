import 'package:flutter/material.dart';

import '../services/google_places_service.dart';
import '../services/institution_api_service.dart';

class VeterinaryDetailScreen extends StatefulWidget {
  final String apiKey;
  final String placeId;
  final String title;

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
  late final Future<PlaceDetails> _detailsFuture;

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

  String? _selectedDate;
  String? _selectedTime;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _detailsFuture =
        InstitutionApiService.fetchInstitutionDetails(widget.placeId);
  }

  void _sendAppointmentRequest(String clinicName) {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Lütfen bir gün, saat ve randevu tipi seçiniz.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Randevu Başvurusu Alındı"),
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

  String _workingHoursText(PlaceDetails details) {
    final hours = details.weekdayText;
    if (hours == null || hours.isEmpty) {
      return "Çalışma saatleri: Bilgi yok";
    }
    return hours.join(" | ");
  }

  String _valueOrFallback(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Bilgi yok";
    }
    return value;
  }

  String _ratingText(PlaceDetails details) {
    final rating = details.rating;
    if (rating == null) {
      return "Bilgi yok";
    }

    final count = details.userRatingsTotal;
    if (count == null) {
      return rating.toStringAsFixed(1);
    }
    return "${rating.toStringAsFixed(1)} ($count oy)";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTimes =
        _selectedDate != null ? _availableSlots[_selectedDate!]! : <String>[];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<PlaceDetails>(
        future: _detailsFuture,
        builder: (context, snap) {
          final isLoading = snap.connectionState != ConnectionState.done;
          final hasError = snap.hasError;
          final details = snap.data;
          final clinicName = details?.name ?? widget.title;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Builder(
                      builder: (_) {
                        if (isLoading) {
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bilgiler yükleniyor...",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(),
                            ],
                          );
                        }

                        if (hasError || details == null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinicName,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text("Detay alınamadı: ${snap.error}"),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              "Adres: ${_valueOrFallback(details.formattedAddress)}",
                            ),
                            _buildInfoRow(
                              Icons.phone_outlined,
                              "Telefon: ${_valueOrFallback(details.phone)}",
                            ),
                            if (details.website != null &&
                                details.website!.trim().isNotEmpty)
                              _buildInfoRow(
                                Icons.language,
                                "Web Sitesi: ${details.website!}",
                              ),
                            _buildInfoRow(Icons.access_time_outlined,
                                _workingHoursText(details)),
                            _buildInfoRow(Icons.star_outline,
                                "Puan: ${_ratingText(details)}"),
                            _buildInfoRow(
                              Icons.map_outlined,
                              "Google Maps: ${_valueOrFallback(details.googleMapsUrl)}",
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "1. Randevu Tipini Seçiniz",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Hizmet Seçiniz",
                    ),
                    initialValue: _selectedType,
                    items: _appointmentTypes
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedType = newValue);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "2. Müsait Günü Seçiniz",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
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
                            color: isSelected
                                ? theme.colorScheme.onSecondary
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "3. Müsait Saati Seçiniz",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedDate == null)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Lütfen yukarıdan bir gün seçiniz.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          setState(() => _selectedTime = time);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.onSecondary
                                  : Colors.transparent,
                              width: isSelected ? 2 : 0,
                            ),
                          ),
                          child: Text(
                            time,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected
                                  ? theme.colorScheme.onSecondary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: (_selectedDate != null &&
                            _selectedTime != null &&
                            _selectedType != null)
                        ? () => _sendAppointmentRequest(clinicName)
                        : null,
                    icon: const Icon(Icons.add_task),
                    label: const Text("Randevu Talebi Gönder"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_selectedDate != null &&
                              _selectedTime != null &&
                              _selectedType != null)
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
