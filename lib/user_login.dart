import 'package:flutter/material.dart';
import 'user_home.dart';

class UserLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Login")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Login (Mock)"),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => UserHomePage()));
          },
        ),
      ),
    );
  }
}
