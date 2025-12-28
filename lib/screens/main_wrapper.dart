// Dosya: lib/screens/main_wrapper.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'home_screen.dart';
import 'pet_care_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';
import 'map_screen.dart';

class MainWrapper extends StatefulWidget {
  final AppUser currentUser;
  final String apiKey;

  const MainWrapper({
    super.key,
    required this.currentUser,
    required this.apiKey,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        HomeScreen(currentUser: widget.currentUser, apiKey: widget.apiKey),
        PetCareScreen(apiKey: widget.apiKey),
        MapScreen(apiKey: widget.apiKey),
        const AppointmentsScreen(),

        // ✅ Profil artık login olan kullanıcıyı alıyor
        ProfileScreen(currentUser: widget.currentUser),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
        indicatorColor: Theme.of(context).colorScheme.secondary,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.health_and_safety_outlined), label: 'Bakım'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Harita'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: 'Randevu'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
