import 'package:flutter/material.dart';

import '../theme/patify_theme.dart';
import '../widgets/category_card.dart';
import 'shelter_list_screen.dart';
import 'veterinary_list_screen.dart';

class PetCareScreen extends StatelessWidget {
  const PetCareScreen({
    super.key,
    required this.apiKey,
  });

  final String apiKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryServices = [
      (
        title: 'Veteriner klinikleri',
        icon: Icons.medical_services_rounded,
        color: PatifyTheme.info,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VeterinaryListScreen(apiKey: apiKey),
            ),
          );
        },
      ),
      (
        title: 'Barınaklar',
        icon: Icons.home_work_rounded,
        color: PatifyTheme.secondary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShelterListScreen(apiKey: apiKey),
            ),
          );
        },
      ),
    ];

    final otherServices = [
      (
        title: 'Beslenme',
        subtitle: 'Öneriler ve günlük bakım notları',
        icon: Icons.restaurant_menu_rounded,
        color: PatifyTheme.success,
      ),
      (
        title: 'Eğitim',
        subtitle: 'Davranış ve temel uyum desteği',
        icon: Icons.school_rounded,
        color: PatifyTheme.accent,
      ),
      (
        title: 'Yürüyüş',
        subtitle: 'Rutin ve aktivite planlaması',
        icon: Icons.directions_walk_rounded,
        color: PatifyTheme.primary,
      ),
      (
        title: 'Bakım',
        subtitle: 'Temizlik ve düzenli bakım ihtiyaçları',
        icon: Icons.content_cut_rounded,
        color: PatifyTheme.textSecondary,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Hizmetler')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PatifyTheme.space20,
          PatifyTheme.space12,
          PatifyTheme.space20,
          120,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(PatifyTheme.space20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(PatifyTheme.radius24),
              border: Border.all(color: PatifyTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bakım ağı', style: theme.textTheme.bodyMedium),
                const SizedBox(height: PatifyTheme.space4),
                Text(
                  'Evcil dostun için temel hizmetler',
                  style: theme.textTheme.headlineMedium,
                ),
                
              ],
            ),
          ),
          const SizedBox(height: PatifyTheme.space24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Öne çıkan alanlar',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: PatifyTheme.space12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: primaryServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: PatifyTheme.space16,
              mainAxisSpacing: PatifyTheme.space16,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final item = primaryServices[index];
              return CategoryCard(
                title: item.title,
                icon: item.icon,
                color: item.color,
                onTap: item.onTap,
              );
            },
          ),
          const SizedBox(height: PatifyTheme.space28),
          Text(
            'Diğer hizmet başlıkları',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: PatifyTheme.space12),
          ...otherServices.map(
            (service) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(PatifyTheme.space16),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: service.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(PatifyTheme.radius16),
                  ),
                  child: Icon(service.icon, color: service.color),
                ),
                title: Text(service.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: PatifyTheme.space4),
                  child: Text(service.subtitle),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: PatifyTheme.textSecondary,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${service.title} bölümü yakında açılacak.'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
