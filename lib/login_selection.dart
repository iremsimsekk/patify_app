import 'package:flutter/material.dart';
import 'user_login.dart';
import 'shelter_login.dart';

class LoginSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patify Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("User Login"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => UserLoginPage()));
              },
            ),
            ElevatedButton(
              child: const Text("Shelter Login"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ShelterLoginPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
