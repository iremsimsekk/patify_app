import 'package:flutter/material.dart';

import '../theme/patify_theme.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evcil Dostlarım")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(PatifyTheme.space24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(PatifyTheme.space20),
              child: Text(
                "Kayıtlı evcil dostlarının listesi burada görünecek.",
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
