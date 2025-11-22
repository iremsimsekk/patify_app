import 'package:flutter/material.dart';
import 'shelter_dashboard.dart';

class ShelterLoginPage extends StatelessWidget {
  const ShelterLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shelter Login")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Login (Mock)"),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ShelterDashboard()));
          },
        ),
      ),
    );
  }
}
