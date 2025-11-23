// Dosya: lib/screens/add_animal_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class AddAnimalScreen extends StatefulWidget {
  final AppUser shelterUser;

  const AddAnimalScreen({super.key, required this.shelterUser});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Değişkenleri
  String _name = '';
  String _type = 'Köpek';
  String _breed = '';
  String _age = '';
  String _gender = 'Erkek';
  double _weight = 0.0;
  
  // GÜNCELLEME: Varsayılan değerler atandı ve listeler oluşturuldu
  String _color = 'Siyah'; 
  String _healthStatus = 'Sağlıklı';
  String _description = '';
  
  // Resim Seçimi (Mock)
  bool _imageSelected = false;

  // GÜNCELLEME: Renk Seçenekleri
  final List<String> _colors = [
    "Siyah",
    "Beyaz",
    "Kahverengi",
    "Gri",
    "Sarı (Golden)",
    "Krem",
    "Siyah & Beyaz",
    "Üç Renkli (Tricolor)",
    "Benekli",
    "Kızıl"
  ];

  // GÜNCELLEME: Sağlık Durumu Seçenekleri
  final List<String> _healthStatuses = [
    "Sağlıklı",
    "Aşıları Tam",
    "Kısırlaştırılmış",
    "Aşıları Tam & Kısırlaştırılmış",
    "Tedavisi Devam Ediyor",
    "Engelli / Özel Bakım",
    "Yaşlı / Düşük Enerjili"
  ];

  void _saveAnimal() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Yeni Hayvan Nesnesi Oluştur
      final newAnimal = Animal(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        shelterId: widget.shelterUser.id,
        name: _name,
        type: _type,
        breed: _breed,
        age: _age,
        gender: _gender,
        weight: _weight,
        color: _color,
        healthStatus: _healthStatus,
        description: _description,
        imagePath: 'assets/animals/dog.jpg', 
      );

      setState(() {
        mockAnimals.insert(0, newAnimal);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dostumuz başarıyla eklendi! 🐾"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Dost Ekle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fotoğraf Yükleme Alanı (Aynı kalıyor)
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _imageSelected = !_imageSelected;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fotoğraf yüklendi (Simülasyon)")),
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[400]!),
                      image: _imageSelected 
                        ? const DecorationImage(image: AssetImage('assets/animals/dog.jpg'), fit: BoxFit.cover)
                        : null,
                    ),
                    child: _imageSelected 
                      ? null 
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                            Text("Fotoğraf", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Temel Bilgiler
              const Text("Temel Bilgiler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: _inputDeco("İsim"),
                      validator: (v) => v!.isEmpty ? "İsim gerekli" : null,
                      onSaved: (v) => _name = v!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _type,
                      decoration: _inputDeco("Tür"),
                      items: ["Köpek", "Kedi", "Kuş", "Diğer"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: _inputDeco("Cins (Örn: Golden, Tekir)"),
                validator: (v) => v!.isEmpty ? "Cins gerekli" : null,
                onSaved: (v) => _breed = v!,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: _inputDeco("Yaş (Örn: 2 Aylık)"),
                      onSaved: (v) => _age = v!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDeco("Cinsiyet"),
                      items: ["Erkek", "Dişi"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Fiziksel & Sağlık
              const Text("Fiziksel & Sağlık", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: _inputDeco("Kilo (kg)"),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => _weight = double.tryParse(v!) ?? 0.0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // GÜNCELLEME: Renk Seçimi Dropdown Oldu
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _color,
                      isExpanded: true, // Metin uzunsa sığsın diye
                      decoration: _inputDeco("Renk"),
                      items: _colors.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _color = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // GÜNCELLEME: Sağlık Durumu Seçimi Dropdown Oldu
              DropdownButtonFormField<String>(
                value: _healthStatus,
                isExpanded: true,
                decoration: _inputDeco("Sağlık Durumu"),
                items: _healthStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _healthStatus = v!),
              ),
              
              const SizedBox(height: 24),

              // Hikaye
              const Text("Hikayesi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                decoration: _inputDeco("Dostumuzun hikayesini anlatın...").copyWith(alignLabelWithHint: true),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? "Açıklama gerekli" : null,
                onSaved: (v) => _description = v!,
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveAnimal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                  child: const Text("Kaydet ve Yayınla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}