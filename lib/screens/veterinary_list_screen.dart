// Dosya: lib/screens/veterinary_list_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'veterinary_detail_screen.dart';

class VeterinaryListScreen extends StatelessWidget {
  const VeterinaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text("Ankara Veteriner Klinikler")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockVeterinaries.length,
        itemBuilder: (context, index) {
          final clinic = mockVeterinaries[index];
          return Card(
            color: theme.cardTheme.color,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.white54, child: Icon(Icons.local_hospital_rounded, color: Colors.blue)),
              title: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(clinic.address),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VeterinaryDetailScreen(clinic: clinic),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}