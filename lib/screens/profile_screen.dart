// Dosya: lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Giriş ekranına dönmek için gerekli

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 4),
              ),
              child: const CircleAvatar(
                radius: 50, 
                backgroundColor: Colors.grey, 
                backgroundImage: AssetImage('assets/user_placeholder.png'), // Varsa asset kullanın yoksa Icon kalabilir
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Irem Simsek", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const Text(
              "irem@example.com", 
              style: TextStyle(color: Colors.grey)
            ),
            const SizedBox(height: 30),
            
            // Menü Listesi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileItem(context, Icons.pets, "My Pets", Colors.blue),
                  _buildProfileItem(context, Icons.history, "Adoption History", Colors.orange),
                  _buildProfileItem(context, Icons.settings, "Settings", Colors.grey),
                  
                  const Divider(height: 30),

                  // LOGOUT BUTONU (GÜNCELLENDİ)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text(
                      "Log Out", 
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                    ), 
                    onTap: () {
                      // Çıkış Yapma Diyaloğu
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Çıkış Yap"),
                          content: const Text("Hesabınızdan çıkmak istediğinize emin misiniz?"),
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
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false, // Geri tuşunu iptal eder
                                );
                              },
                              child: const Text("Çıkış Yap", style: TextStyle(color: Colors.red)),
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

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}