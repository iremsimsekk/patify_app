import 'package:flutter/material.dart';

import '../theme/patify_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sahiplenme Geçmişi")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(PatifyTheme.space24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(PatifyTheme.space20),
              child: Text(
                "Geçmiş sahiplenme kayıtları burada listelenecek.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
