import 'package:flutter/material.dart';

import '../theme/patify_theme.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Randevular")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PatifyTheme.space20,
          PatifyTheme.space12,
          PatifyTheme.space20,
          PatifyTheme.space28,
        ),
        children: [
          Text(
            "Yaklaşan randevular",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            "Planlarını tek bir yerde düzenli ve net şekilde takip et.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PatifyTheme.space20),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(PatifyTheme.space16),
              leading: Container(
                padding: const EdgeInsets.all(PatifyTheme.space8),
                decoration: BoxDecoration(
                  color: PatifyTheme.primarySoft,
                  borderRadius: BorderRadius.circular(PatifyTheme.radius12),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: PatifyTheme.primary,
                ),
              ),
              title: const Text("Dr. Smith - Aşı kontrolü"),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: PatifyTheme.space4),
                child: Text("Yarın, 10.00"),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: PatifyTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Randevu Oluştur"),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}
