import 'package:flutter/material.dart';
import 'login_selection.dart';
import 'user_login.dart';
import 'shelter_login.dart';
import 'user_home.dart';
import 'animal_detail.dart';
import 'shelter_dashboard.dart';

void main() {
  runApp(const PatifyApp());
}

class PatifyApp extends StatelessWidget {
  const PatifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patify Prototype',
      debugShowCheckedModeBanner: false,
      home: LoginSelectionPage(),
    );
  }
}
