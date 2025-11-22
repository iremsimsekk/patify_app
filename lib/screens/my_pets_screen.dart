import 'package:flutter/material.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Pets")),
      body: const Center(
        child: Text("Sahiplendiğim hayvanlarımın listesi burada olacak."),
      ),
    );
  }
}
