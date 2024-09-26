import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:moonhike/core/widgets/address_search_widget.dart';
import 'package:moonhike/data/models/route_service.dart';
import 'package:moonhike/data/repositories/route_repository.dart';
import 'package:moonhike/domain/use_cases/get_routes_use_case.dart';

import '../../core/utils/location_utils.dart';
import 'login.dart';
 
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  bool _showStartRouteButton = false;
  Set<Polyline> _polylines = {};
  int _selectedRouteIndex = 0;
  List<List<LatLng>> _routes = [];

  final RouteRepository routeRepository = RouteRepository(RouteService('AIzaSyDNHOPdlWDOqsFiL9_UQCkg2fnlpyww6A4')); // Usa tu API key
  late GetRoutesUseCase getRoutesUseCase;

  _MapScreenState() {
    getRoutesUseCase = GetRoutesUseCase(routeRepository);
  }

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  // Establece la ubicación inicial y actualiza cuando el usuario se mueve
  void _setInitialLocation() async {
    try {
      Position position = await LocationUtils.getUserLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _addMarker(
          _currentPosition!,
          'currentLocation',
          'Mi Ubicación',
        );
      });
      _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    } catch (e) {
      setState(() {
        _currentPosition = LatLng(25.6866, -100.3161);  // Ubicación por defecto
        _addMarker(_currentPosition!, 'defaultLocation', 'Ubicación por Defecto: Monterrey');
      });
      _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  // Actualiza la posición actual antes de realizar cualquier acción
  Future<void> _updateCurrentLocation() async {
    Position position = await LocationUtils.getUserLocation();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  // Función para añadir marcadores
  void _addMarker(LatLng position, String markerId, String title, {String? snippet}) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(
          title: title,
          snippet: snippet,
        ),
      ));
    });
  }

  // Función para cerrar sesión
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Inicia las rutas
  Future<void> _startRoutes() async {
    await _updateCurrentLocation(); // Actualiza la ubicación antes de iniciar las rutas
    if (_currentPosition == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una ubicación')),
      );
      return;
    }

    try {
      _routes = await getRoutesUseCase.execute(_currentPosition!, _selectedLocation!);

      setState(() {
        _polylines.clear();
        for (int i = 0; i < _routes.length; i++) {
          _polylines.add(Polyline(
            polylineId: PolylineId('route_$i'),
            points: _routes[i],
            color: i == _selectedRouteIndex ? Colors.blue : Colors.grey,
            width: 5,
          ));
        }
      });
    } catch (e) {
      print('Error obteniendo las rutas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener las rutas')),
      );
    }
  }

  // Selecciona una ruta
  void _selectRoute(int index) {
    setState(() {
      _selectedRouteIndex = index;
      _polylines.clear();
      for (int i = 0; i < _routes.length; i++) {
        _polylines.add(Polyline(
          polylineId: PolylineId('route_$i'),
          points: _routes[i],
          color: i == _selectedRouteIndex ? Colors.blue : Colors.grey,
          width: 5,
        ));
      }
    });
  }

  // Reportar un problema
  void _reportIssue(BuildContext context) async {
    await _updateCurrentLocation(); // Actualiza la ubicación antes de hacer el reporte
    User? currentUser = FirebaseAuth.instance.currentUser;
    String email = currentUser?.email ?? 'Usuario Desconocido';
    String? selectedIssue;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Qué desea reportar?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('No hay luz'),
                leading: Radio<String>(
                  value: 'No hay luz',
                  groupValue: selectedIssue,
                  onChanged: (value) {
                    setState(() {
                      selectedIssue = value;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('Zona conflictiva'),
                leading: Radio<String>(
                  value: 'Zona conflictiva',
                  groupValue: selectedIssue,
                  onChanged: (value) {
                    setState(() {
                      selectedIssue = value;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedIssue != null) {
      String currentTime = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
      _addMarker(_currentPosition!, 'issue_${_markers.length}', 'Reporte: $selectedIssue',
          snippet: 'Usuario: $email\nHora: $currentTime');
      _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu'),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar Sesión'),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text('MoonHike')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? LatLng(25.6866, -100.3161),
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              if (_currentPosition != null) {
                _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
              }
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: AddressSearchWidget(
              onLocationSelected: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                  _addMarker(_selectedLocation!, 'selectedLocation', 'Ubicación seleccionada');
                  _controller?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
                  _showStartRouteButton = true;
                });
              },
            ),
          ),
          if (_showStartRouteButton)
            Positioned(
              bottom: 100,
              left: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: _startRoutes,
                child: Text('Iniciar Rutas'),
              ),
            ),
          if (_routes.isNotEmpty)
            Positioned(
              bottom: 170,
              left: 10,
              right: 10,
              child: Column(
                children: List.generate(_routes.length, (index) {
                  return ElevatedButton(
                    onPressed: () => _selectRoute(index),
                    child: Text('Seleccionar Ruta ${index + 1}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: index == _selectedRouteIndex ? Colors.blue : Colors.grey,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _reportIssue(context),
        child: Icon(Icons.report),
        backgroundColor: Colors.red,
      ),
    );
  }
}
