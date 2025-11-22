import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock State'ler
  bool _isNotificationsEnabled = true;
  String _selectedTheme = 'System Default'; // 'System Default', 'Light', 'Dark'

  // Kullanıcı tarafından yapılan değişiklikleri kaydetmek için mock bir fonksiyon
  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ayarlar başarıyla kaydedildi!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        // Kaydet butonu
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text("Save",
                style: TextStyle(
                    color: theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Hesap Ayarları Grubu
          _buildSettingsHeader(theme, "Account Settings"),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Profil düzenleme sayfasına yönlendir
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil Düzenleme (TBD)")));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Şifre değiştirme sayfasına yönlendir
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Şifre Değiştirme (TBD)")));
            },
          ),

          const Divider(height: 30),

          // 2. Uygulama Ayarları Grubu
          _buildSettingsHeader(theme, "App Preferences"),

          // Bildirim Ayarı (Switch)
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

          // Tema Seçimi (Dropdown)
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text("App Theme"),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTheme = newValue;
                    // TODO: Gerçekte temayı main.dart içinde değiştirmeniz gerekir.
                  });
                }
              },
              items: <String>['System Default', 'Light', 'Dark']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 30),

          // 3. Bilgi Grubu
          _buildSettingsHeader(theme, "Information"),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About Patify"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Hakkında sayfasına yönlendir
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Uygulama Hakkında (TBD)")));
            },
          ),
        ],
      ),
    );
  }

  // Ayarlar başlık stilini oluşturan yardımcı fonksiyon
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
