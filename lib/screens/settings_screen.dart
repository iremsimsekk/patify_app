// Dosya: lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../theme/patify_theme.dart'; // ThemeManager'a erişmek için

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationsEnabled = true;

  // Tema modunu String'e çevirme yardımcısı
  String _getThemeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return 'System Default';
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark: return 'Dark';
    }
  }

  // String'i Tema moduna çevirme yardımcısı
  ThemeMode _getThemeMode(String selection) {
    switch (selection) {
      case 'Light': return ThemeMode.light;
      case 'Dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          TextButton(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ayarlar kaydedildi (Simülasyon)")),
              );
            },
            child: Text("Save",
                style: TextStyle(
                    color: theme.colorScheme.onSurface, // Dark mod uyumlu renk
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsHeader(theme, "Account Settings"),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const Divider(height: 30),

          _buildSettingsHeader(theme, "App Preferences"),

          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text("Enable Notifications"),
            value: _isNotificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _isNotificationsEnabled = value;
              });
            },
          ),

          // TEMA SEÇİMİ (GÜNCELLENDİ)
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text("App Theme"),
            trailing: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeManager.themeNotifier,
              builder: (context, currentMode, _) {
                return DropdownButton<String>(
                  value: _getThemeString(currentMode),
                  underline: Container(), // Alt çizgiyi kaldır
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Tema Yöneticisi üzerinden tüm uygulamayı güncelle
                      ThemeManager.setTheme(_getThemeMode(newValue));
                    }
                  },
                  items: <String>['System Default', 'Light', 'Dark']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          const Divider(height: 30),

          _buildSettingsHeader(theme, "Information"),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About Patify"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}