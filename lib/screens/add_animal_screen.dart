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
  String _color = '';
  String _healthStatus = '';
  String _description = '';
  
  // Resim Seçimi (Mock - Gerçek dosya seçimi yerine simülasyon)
  bool _imageSelected = false;

  void _saveAnimal() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Yeni Hayvan Nesnesi Oluştur
      final newAnimal = Animal(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Benzersiz ID
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
        // Resim seçildiyse varsayılan köpek fotosunu, seçilmediyse placeholder kullan
        imagePath: 'assets/animals/dog.jpg', 
      );

      // Listeye Ekle (RAM üzerinde)
      setState(() {
        mockAnimals.insert(0, newAnimal); // En başa ekle
      });

      // Başarı Mesajı ve Geri Dönüş
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dostumuz başarıyla eklendi! 🐾"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // true: liste güncellensin diye
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
              // Fotoğraf Yükleme Alanı (Mock)
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
                    // DÜZELTME: 'value' yerine 'initialValue' kullanıldı.
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
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
                    // DÜZELTME: 'value' yerine 'initialValue' kullanıldı.
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
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
                  Expanded(
                    child: TextFormField(
                      decoration: _inputDeco("Renk"),
                      onSaved: (v) => _color = v!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDeco("Sağlık Durumu (Aşılar vb.)"),
                onSaved: (v) => _healthStatus = v!,
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