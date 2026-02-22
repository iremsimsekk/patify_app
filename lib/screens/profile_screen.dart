// Dosya: lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Giriş ekranına dönmek için gerekli
import 'my_pets_screen.dart'; // YENİ EKLENDİ
import 'history_screen.dart'; // YENİ EKLENDİ
import 'settings_screen.dart'; // YENİ EKLENDİ

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Navigasyon fonksiyonunu genel olarak tanımlayalım
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profil Fotoğrafı
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 4),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage(
                    'assets/user_placeholder.png'), // Varsa asset kullanın yoksa Icon kalabilir
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Merve Nair",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("merve@example.com",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // Menü Listesi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // --- Tıklanabilir hale getirilen öğeler ---
                  _buildProfileItem(
                    context,
                    Icons.pets,
                    "My Pets",
                    Colors.blue,
                    () => _navigateToScreen(
                        context, const MyPetsScreen()), // NAVİGASYON EKLENDİ
                  ),
                  _buildProfileItem(
                    context,
                    Icons.history,
                    "Adoption History",
                    Colors.orange,
                    () => _navigateToScreen(
                        context, const HistoryScreen()), // NAVİGASYON EKLENDİ
                  ),
                  _buildProfileItem(
                    context,
                    Icons.settings,
                    "Settings",
                    Colors.grey,
                    () => _navigateToScreen(
                        context, const SettingsScreen()), // NAVİGASYON EKLENDİ
                  ),
                  // ----------------------------------------

                  const Divider(height: 30),

                  // LOGOUT BUTONU (Zaten çalışıyordu)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red
                            .withOpacity(0.1), // withValues yerine withOpacity
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text("Log Out",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Çıkış Yapma Diyaloğu (Mevcut kod)
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Çıkış Yap"),
                          content: const Text(
                              "Hesabınızdan çıkmak istediğinize emin misiniz?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("İptal"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Diyaloğu kapat
                                Navigator.pop(ctx);
                                // Giriş sayfasına yönlendir ve geçmişi sil
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                  (route) => false, // Geri tuşunu iptal eder
                                );
                              },
                              child: const Text("Çıkış Yap",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildProfileItem fonksiyonu onTap parametresini kabul edecek şekilde güncellendi
  Widget _buildProfileItem(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), // withValues yerine withOpacity
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap, // BURADA YENİ ONTAP KULLANILDI
    );
  }
}
