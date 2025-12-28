// Dosya: lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart'; // AppUser için
import 'login_screen.dart';
import 'my_pets_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppUser currentUser;

  const ProfileScreen({super.key, required this.currentUser});

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Ad Soyad (yoksa name’i göster)
    final fullName = (currentUser.firstName != null && currentUser.lastName != null)
        ? "${currentUser.firstName} ${currentUser.lastName}"
        : currentUser.name;

    // ✅ Email
    final email = currentUser.email;

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
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/user_placeholder.png'),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Dinamik isim/email
            Text(
              fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileItem(
                    context,
                    Icons.pets,
                    "My Pets",
                    Colors.blue,
                    () => _navigateToScreen(context, const MyPetsScreen()),
                  ),
                  _buildProfileItem(
                    context,
                    Icons.history,
                    "Adoption History",
                    Colors.orange,
                    () => _navigateToScreen(context, const HistoryScreen()),
                  ),
                  _buildProfileItem(
                    context,
                    Icons.settings,
                    "Settings",
                    Colors.grey,
                    () => _navigateToScreen(context, const SettingsScreen()),
                  ),
                  const Divider(height: 30),

                  // LOGOUT
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text(
                      "Log Out",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
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
                                Navigator.pop(ctx);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
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

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
