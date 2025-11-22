import 'package:flutter/material.dart';
import 'fake_data.dart';
import 'animal_detail.dart';

class UserHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Animals Available for Adoption")),
      body: ListView.builder(
        itemCount: animals.length,
        itemBuilder: (context, index) {
          final animal = animals[index];
          return Card(
            child: ListTile(
              leading: Image.asset(animal["image"], width: 60),
              title: Text(animal["name"]),
              subtitle: Text("${animal["type"]} - ${animal["gender"]}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnimalDetailPage(animal: animal),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
