// Dosya: lib/screens/animal_detail_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class AnimalDetailScreen extends StatelessWidget {
  final Animal animal;

  const AnimalDetailScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(animal.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(animal.imagePath, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst Bilgi Kartları (Cins, Yaş, Cinsiyet)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBadge(context, "Tür", animal.type, Colors.blue[50]!, Colors.blue),
                      _buildInfoBadge(context, "Cinsiyet", animal.gender, Colors.pink[50]!, Colors.pink),
                      _buildInfoBadge(context, "Yaş", animal.age, Colors.orange[50]!, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Detaylı Özellikler Grid'i
                  Text("Özellikler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow("Cins", animal.breed),
                        const Divider(),
                        _buildDetailRow("Kilo", "${animal.weight} kg"),
                        const Divider(),
                        _buildDetailRow("Renk", animal.color),
                        const Divider(),
                        _buildDetailRow("Sağlık", animal.healthStatus),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text("Hikayesi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Text(
                    animal.description,
                    style: TextStyle(fontSize: 16, height: 1.6, color: textColor.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 40),
                  
                  // Sahiplen Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Başvuru Alındı ❤️"),
                            content: Text("${animal.name} ile tanışmak için talebiniz barınağa iletildi."),
                            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tamam"))],
                          ),
                        );
                      },
                      child: const Text("Sahiplenmek İstiyorum"),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, String title, String value, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: text)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}