import 'package:flutter/material.dart';
import '../widgets/category_card.dart';
import 'veterinary_list_screen.dart'; // Yeni import

class PetCareScreen extends StatelessWidget {
  const PetCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"title": "Veterinary", "icon": Icons.medical_services, "color": Colors.blue},
      {"title": "Nutrition", "icon": Icons.restaurant, "color": Colors.green},
      {"title": "Training", "icon": Icons.sports_baseball, "color": Colors.orange},
      {"title": "Walking", "icon": Icons.directions_walk, "color": Colors.purple},
      {"title": "Grooming", "icon": Icons.content_cut, "color": Colors.pink},
      {"title": "Store", "icon": Icons.storefront, "color": Colors.teal},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Pet Care")),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return CategoryCard(
            title: cat["title"] as String,
            icon: cat["icon"] as IconData,
            color: cat["color"] as Color,
            onTap: () {
              if (cat["title"] == "Veterinary") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VeterinaryListScreen()));
              } else {
                // Diğerleri için mock SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${cat["title"]} Sayfası (Yapım Aşamasında)")),
                );
              }
            },
          );
        },
      ),
    );
  }
}