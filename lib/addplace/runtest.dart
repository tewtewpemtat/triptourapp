import 'package:flutter/material.dart';
import 'test.dart'; // Assume your MapsWidget class is in maps_widget.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Embed Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapsWidget(), // Display your MapsWidget as the home screen
    );
  }
}
