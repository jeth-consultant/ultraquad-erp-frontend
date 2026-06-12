import 'package:flutter/material.dart';

/// Generic placeholder used while a feature screen's UI is built out.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
