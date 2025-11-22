// Dosya: lib/screens/shelter_profile_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'login_screen.dart';

class ShelterProfileScreen extends StatelessWidget {
  final AppUser shelterUser;

  const ShelterProfileScreen({super.key, required this.shelterUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar yok çünkü Dashboard içinde sekme olarak veya modal olarak açılabilir. 
      // Ama bağımsız sayfa gibi tasarlayalım:
      appBar: AppBar(
        title: const Text("Kurumsal Profil"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profil Resmi
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, size: 60, color: theme.colorScheme.secondary),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(shelterUser.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const Text("Onaylı Kurumsal Hesap", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            
            const SizedBox(height: 30),

            // Bilgiler
            _buildSectionHeader("İletişim Bilgileri"),
            Card(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  _buildInfoTile(Icons.phone, "Telefon", shelterUser.phoneNumber ?? "Girilmemiş"),
                  const Divider(height: 1),
                  _buildInfoTile(Icons.map, "Adres", shelterUser.address ?? "Girilmemiş"),
                  const Divider(height: 1),
                  _buildInfoTile(Icons.language, "Web Sitesi", shelterUser.website ?? "Girilmemiş"),
                ],
              ),
            ),

            _buildSectionHeader("Kurum Detayları"),
            Card(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  _buildInfoTile(Icons.access_time, "Çalışma Saatleri", shelterUser.workingHours ?? "Belirtilmemiş"),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Hakkımızda", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(shelterUser.about ?? "Açıklama yok.", style: const TextStyle(height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Çıkış Butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Çıkış Diyaloğu
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Çıkış Yap"),
                      content: const Text("Hesabınızdan çıkmak istediğinize emin misiniz?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
                        TextButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
                          child: const Text("Çıkış", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Hesaptan Çıkış Yap", style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
      trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
      onTap: () {}, // Düzenleme mock
    );
  }
}