import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import 'appointments_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'pet_care_screen.dart';
import 'profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({
    super.key,
    required this.currentUser,
    required this.apiKey,
  });

  final AppUser currentUser;
  final String apiKey;

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late final List<Widget?> _loadedPages;

  @override
  void initState() {
    super.initState();
    _loadedPages = List<Widget?>.filled(5, null);
    _loadedPages[0] = _buildPage(0);
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          currentUser: widget.currentUser,
          apiKey: widget.apiKey,
        );
      case 1:
        return PetCareScreen(apiKey: widget.apiKey);
      case 2:
        return MapScreen(apiKey: widget.apiKey);
      case 3:
        return const AppointmentsScreen();
      case 4:
        return ProfileScreen(currentUser: widget.currentUser);
      default:
        return const SizedBox.shrink();
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
      _loadedPages[index] ??= _buildPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _loadedPages
            .map((page) => page ?? const SizedBox.shrink())
            .toList(growable: false),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
        indicatorColor: Theme.of(context).colorScheme.secondary,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_outlined),
            label: 'Bakim',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Harita',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Randevu',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
