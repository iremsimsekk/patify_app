// Dosya: lib/screens/veterinary_detail_screen.dart (GÜNCELLENDİ)
import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class VeterinaryDetailScreen extends StatefulWidget {
  final VeterinaryClinic clinic;

  const VeterinaryDetailScreen({super.key, required this.clinic});

  @override
  State<VeterinaryDetailScreen> createState() => _VeterinaryDetailScreenState();
}

class _VeterinaryDetailScreenState extends State<VeterinaryDetailScreen> {
  // Mock müsait zaman dilimleri, artık Map yapısıyla günleri de tutuyor
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
  String? _selectedDate; // "Pazartesi, 24/11" gibi
  String? _selectedTime; // "14:00" gibi
  String? _selectedType;

  void _sendAppointmentRequest() {
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
          "Klinik: ${widget.clinic.name}\n"
          "Tarih/Saat: $_selectedDate, $_selectedTime\n" // Gün ve Saati birlikte gösteriyoruz
          "Hizmet: $_selectedType",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Seçimleri sıfırla
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Seçili günün saatlerini al, eğer gün seçili değilse boş liste
    final currentTimes = _selectedDate != null ? _availableSlots[_selectedDate!]! : [];
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.clinic.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Klinik Bilgileri (Aynı kalıyor)
            Card(
              color: theme.colorScheme.primary.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.clinic.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on_outlined, widget.clinic.address),
                    _buildInfoRow(Icons.phone_outlined, widget.clinic.phoneNumber),
                    _buildInfoRow(Icons.access_time_outlined, widget.clinic.workingHours),
                    const Divider(height: 24),
                    Text("Hakkımızda:", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    Text(widget.clinic.about, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 1. Randevu Tipi Seçimi (Aynı kalıyor)
            Text("1. Randevu Tipini Seçiniz", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: InputBorder.none, hintText: "Hizmet Seçiniz"),
                value: _selectedType,
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

            // 2. Müsait Gün Seçimi
            Text("2. Müsait Günü Seçiniz", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            
            // Günleri listeleyen yatay kaydırılabilir alan (Chip benzeri kartlar)
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
                            _selectedTime = null; // Yeni gün seçilince saati sıfırla
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

            // 3. Müsait Saat Seçimi (Sadece gün seçiliyse gösterilir)
            Text("3. Müsait Saati Seçiniz", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
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
            
            // Randevu Al Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (_selectedDate != null && _selectedTime != null && _selectedType != null)
                  ? _sendAppointmentRequest
                  : null, // Koşul sağlanmazsa butonu devre dışı bırak
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}