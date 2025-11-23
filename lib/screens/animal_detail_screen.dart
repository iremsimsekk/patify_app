// Dosya: lib/screens/animal_detail_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/patify_theme.dart'; // YENİ: DarkImageFixer için

class AnimalDetailScreen extends StatelessWidget {
  final Animal animal;
  final bool isOwner; // Bu ilanın sahibi (barınak) mı görüntülüyor?

  const AnimalDetailScreen({
    super.key, 
    required this.animal,
    this.isOwner = false, // Varsayılan olarak hayır
  });

  // İlanı Silme Fonksiyonu
  void _deleteListing(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("İlanı Sil"),
        content: const Text("Bu ilanı kalıcı olarak silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          TextButton(
            onPressed: () {
              // Listeden sil
              mockAnimals.removeWhere((a) => a.id == animal.id);
              
              Navigator.pop(ctx); // Dialogu kapat
              Navigator.pop(context, true); // Sayfayı kapat ve yenileme sinyali gönder
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("İlan silindi.")),
              );
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Sahiplendirildi İşaretleme Fonksiyonu
  void _markAsAdopted(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Harika Haber! 🎉"),
        content: Text("${animal.name} yuvalandı olarak işaretlensin mi? Bu işlem ilanı listeden kaldıracaktır."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          TextButton(
            onPressed: () {
              // Listeden sil
              mockAnimals.removeWhere((a) => a.id == animal.id);

              Navigator.pop(ctx); // Dialogu kapat
              Navigator.pop(context, true); // Sayfayı kapat ve yenileme sinyali gönder

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${animal.name} için çok mutluyuz! ❤️"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Evet, Yuvalandı!", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tema Renkleri
    const Color pastelGreen = Color(0xFFBDE3C3);
    const Color darkTextPrimary = Color(0xFF1B4242);
    const Color darkTextSecondary = Color(0xFF3A0519);

    return Scaffold(
      backgroundColor: pastelGreen,
      body: CustomScrollView(
        slivers: [
          // 1. Resim Alanı
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: pastelGreen,
            iconTheme: const IconThemeData(color: darkTextPrimary),
            flexibleSpace: FlexibleSpaceBar(
              // GÜNCELLEME: Resmi DarkImageFixer ile sarıyoruz ki negatif görünmesin
              background: DarkImageFixer(
                child: Image.asset(
                  animal.imagePath, 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // İsim ve Cins
                    Text(
                      animal.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: darkTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      animal.breed,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkTextPrimary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Üst Bilgi Kartları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoBadge("Tür", animal.type, Colors.blue[100]!, Colors.blue[900]!),
                        _buildInfoBadge("Cinsiyet", animal.gender, Colors.pink[100]!, Colors.pink[900]!),
                        _buildInfoBadge("Yaş", animal.age, Colors.orange[100]!, Colors.orange[900]!),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Detaylı Özellikler
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
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 40),
                    
                    // --- BUTON ALANI ---
                    if (isOwner)
                      // EĞER BARINAK HESABIYSA: Yönetim Butonları
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () => _markAsAdopted(context),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Yuvalandı Olarak İşaretle"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF81C784), // Yeşil ton
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () => _deleteListing(context),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text("İlanı Sil"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red[700],
                                side: BorderSide(color: Colors.red[200]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // EĞER NORMAL KULLANICIYSA: Sahiplen Butonu
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
                            backgroundColor: const Color(0xFFA3CCDA),
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