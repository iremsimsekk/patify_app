import 'package:flutter/material.dart';

class AnimalDetailPage extends StatelessWidget {
  final Map<String, dynamic> animal;

  const AnimalDetailPage({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(animal["name"])),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(animal["image"],
              width: double.infinity, height: 250, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Type: ${animal["type"]}",
                    style: const TextStyle(fontSize: 18)),
                Text("Age: ${animal["age"]}",
                    style: const TextStyle(fontSize: 18)),
                Text("Gender: ${animal["gender"]}",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    child: const Text("Adopt"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Adoption Request"),
                          content: const Text(
                              "Your adoption request has been sent!"),
                          actions: [
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
