// Dosya: lib/screens/main_wrapper.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'home_screen.dart';
import 'pet_care_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';
// Logout için

class MainWrapper extends StatefulWidget {
  final AppUser currentUser;
  const MainWrapper({super.key, required this.currentUser});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  
  // Sayfaları build içinde oluşturuyoruz ki currentUser'a erişebilelim
  List<Widget> get _pages => [
    HomeScreen(currentUser: widget.currentUser),
    const PetCareScreen(),
    const AppointmentsScreen(),
    const ProfileScreen(), // Profile Screen'e de kullanıcıyı yollayabilirsiniz
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // AnimatedSwitcher yerine IndexedStack kullanmak state'i korur
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
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: 'Randevu'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}