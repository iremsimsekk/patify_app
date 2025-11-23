// Dosya: lib/screens/animal_detail_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class AnimalDetailScreen extends StatelessWidget {
  final Animal animal;

  const AnimalDetailScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    // Tema Renkleri
    const Color pastelGreen = Color(0xFFBDE3C3);
    const Color darkTextPrimary = Color(0xFF1B4242);
    const Color darkTextSecondary = Color(0xFF3A0519);

    return Scaffold(
      backgroundColor: pastelGreen, // Arka plan rengi
      body: CustomScrollView(
        slivers: [
          // 1. Resim Alanı (Yazısız)
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: pastelGreen,
            iconTheme: const IconThemeData(color: darkTextPrimary), // Geri butonu rengi
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                animal.imagePath, 
                fit: BoxFit.cover,
              ),
              // BURADAKİ TITLE'I KALDIRDIK (Artık resim üzerinde yazı yok)
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5), // Geri butonu arkasına hafif beyazlık
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 2. Bilgiler Alanı
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: pastelGreen,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Her şeyi ortala
                  children: [
                    
                    // --- YENİ EKLENEN İSİM ALANI ---
                    Text(
                      animal.name,
                      style: const TextStyle(
                        fontSize: 32, // Büyük Font
                        fontWeight: FontWeight.bold,
                        color: darkTextSecondary, // Koyu Bordo Rengi
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Cins Bilgisi (İsmin altında)
                    Text(
                      animal.breed,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkTextPrimary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Üst Bilgi Kartları (Tür, Cinsiyet, Yaş)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoBadge("Tür", animal.type, Colors.blue[100]!, Colors.blue[900]!),
                        _buildInfoBadge("Cinsiyet", animal.gender, Colors.pink[100]!, Colors.pink[900]!),
                        _buildInfoBadge("Yaş", animal.age, Colors.orange[100]!, Colors.orange[900]!),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Detaylı Özellikler Tablosu
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Özellikler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextPrimary)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Kilo", "${animal.weight} kg"),
                          const Divider(),
                          _buildDetailRow("Renk", animal.color),
                          const Divider(),
                          _buildDetailRow("Sağlık", animal.healthStatus),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Hikayesi
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Hikayesi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextPrimary)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      animal.description,
                      style: TextStyle(fontSize: 16, height: 1.6, color: darkTextPrimary.withValues(alpha: 0.9)),
                      textAlign: TextAlign.justify, // Metni iki yana yasla
                    ),
                    const SizedBox(height: 40),
                    
                    // Sahiplen Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Başvuru Alındı ❤️"),
                              content: Text("${animal.name} ile tanışmak için talebiniz barınağa iletildi."),
                              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tamam"))],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA3CCDA), // Pastel Mavi Buton
                          foregroundColor: darkTextPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Sahiplenmek İstiyorum", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String title, String value, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: text)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4242))),
        ],
      ),
    );
  }
}