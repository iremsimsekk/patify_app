import 'package:flutter/material.dart';
import 'fake_data.dart';

class ShelterDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shelter Dashboard")),
      body: ListView.builder(
        itemCount: animals.length,
        itemBuilder: (context, index) {
          final animal = animals[index];
          return Card(
            child: ListTile(
              leading: Image.asset(animal["image"], width: 60),
              title: Text(animal["name"]),
              subtitle: Text("${animal["type"]} - ${animal["gender"]}"),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add Animal (Mock Action)")),
          );
        },
      ),
    );
  }
}
