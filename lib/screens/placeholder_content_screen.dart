import 'package:flutter/material.dart';

class PlaceholderContentScreen extends StatelessWidget {
  const PlaceholderContentScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Yakinda eklenecek',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
