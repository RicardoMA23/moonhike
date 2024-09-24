import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moonhike/presentation/screens/login.dart';
import 'firebase_options.dart'; // Asegúrate de tener tu archivo de configuración de Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Simple de Login/Registro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Página inicial que cargará al abrir la app
    );
  }
}
