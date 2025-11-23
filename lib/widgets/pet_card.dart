// Dosya: lib/widgets/pet_card.dart
import 'package:flutter/material.dart';
import '../theme/patify_theme.dart'; // DarkImageFixer için gerekli

class PetCard extends StatelessWidget {
  final String name;
  final String age;
  final String imagePath;
  final Color backgroundColor;

  const PetCard({
    super.key,
    required this.name,
    required this.age,
    required this.imagePath,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              // GÜNCELLEME: Resmi DarkImageFixer ile sarıyoruz
              child: DarkImageFixer(
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: AssetImage(imagePath),
                  onBackgroundImageError: (_, __) {},
                  backgroundColor: Colors.grey[200],
                  child: imagePath.isEmpty ? const Icon(Icons.pets, size: 30) : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              age,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center, // Çok satırlı olursa ortalasın
            ),
          ],
        ),
      ),
    );
  }
}