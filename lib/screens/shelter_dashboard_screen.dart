// Dosya: lib/screens/shelter_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'login_screen.dart';

class ShelterDashboardScreen extends StatelessWidget {
  final AppUser shelterUser;

  const ShelterDashboardScreen({super.key, required this.shelterUser});

  @override
  Widget build(BuildContext context) {
    final myAnimals = getAnimalsByShelter(shelterUser.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Barınak Yönetim Paneli"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Hoşgeldiniz, ${shelterUser.name}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // İstatistik Kartları
          const Row(
            children: [
              Expanded(child: Card(child: Padding(padding: EdgeInsets.all(16.0), child: Column(children: [Text("3"), Text("Bekleyen")])))),
              Expanded(child: Card(child: Padding(padding: EdgeInsets.all(16.0), child: Column(children: [Text("12"), Text("Sahiplendirilen")])))),
            ],
          ),
          const SizedBox(height: 24),

          const Text("Hayvanlarınız", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myAnimals.length,
            itemBuilder: (context, index) {
              final animal = myAnimals[index];
              return Card(
                child: ListTile(
                  leading: Image.asset(animal.imagePath, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(animal.name),
                  subtitle: Text("${animal.type} - ${animal.gender}"),
                  trailing: IconButton(icon: const Icon(Icons.edit), onPressed: (){}),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Hayvan Ekleme (Mock)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hayvan Ekleme Sayfası (Demo)")));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}