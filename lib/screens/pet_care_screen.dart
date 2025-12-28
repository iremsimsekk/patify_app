import 'package:flutter/material.dart';
import '../widgets/category_card.dart';
import 'veterinary_list_screen.dart';
import 'shelter_list_screen.dart';

class PetCareScreen extends StatelessWidget {
  const PetCareScreen({
    super.key,
    required this.apiKey,
  });

  final String apiKey;

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"title": "Veterinary", "icon": Icons.medical_services, "color": Colors.blue},
      {"title": "Shelters", "icon": Icons.store, "color": Colors.teal},
      {"title": "Nutrition", "icon": Icons.restaurant, "color": Colors.green},
      {"title": "Training", "icon": Icons.sports_baseball, "color": Colors.orange},
      {"title": "Walking", "icon": Icons.directions_walk, "color": Colors.purple},
      {"title": "Grooming", "icon": Icons.content_cut, "color": Colors.pink},
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
          final title = cat["title"] as String;

          return CategoryCard(
            title: title,
            icon: cat["icon"] as IconData,
            color: cat["color"] as Color,
            onTap: () {
              if (title == "Veterinary") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VeterinaryListScreen(apiKey: apiKey)),
                );
              } else if (title == "Shelters") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ShelterListScreen(apiKey: apiKey)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$title Sayfası (Yapım Aşamasında)")),
                );
              }
            },
          );
        },
      ),
    );
  }
}
