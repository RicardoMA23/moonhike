import 'package:flutter/material.dart';
import 'package:moonhike/presentation/screens/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapa con Mi Ubicación',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(), // Llamando a MapScreen que está en home.dart
    );
  }
}