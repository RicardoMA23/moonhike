//Este archivo contiene la pantalla de detalles del perfil

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Imagen de perfil
            CircleAvatar(
              radius: 60.0,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Imagen simulada
            ),
            SizedBox(height: 20.0),

            // Nombre del usuario
            Text(
              'Nombre del Usuario',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),

            // Correo electrónico
            Text(
              'usuario@correo.com',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20.0),

            // Botón de Editar perfil
            ElevatedButton.icon(
              onPressed: () {
                // Funcionalidad de edición de perfil
                print('Editar perfil');
              },
              icon: Icon(Icons.edit),
              label: Text('Editar perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20.0),

            // Botón de Logout
            ElevatedButton.icon(
              onPressed: () {
                // Simular logout o navegación
                print('Cerrar sesión');
              },
              icon: Icon(Icons.logout),
              label: Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ], 
        ),
      ),
    );
  }
}
