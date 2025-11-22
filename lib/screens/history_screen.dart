import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adoption History")),
      body: const Center(
        child: Text("Geçmiş sahiplenme kayıtları burada olacak."),
      ),
    );
  }
}
