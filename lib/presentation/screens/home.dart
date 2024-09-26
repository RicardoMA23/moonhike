/*Esta es la pantalla principal que usa todos los componentes anteriores para mostrar el mapa,
las rutas, y el widget de búsqueda.*/

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moonhike/data/models/route_service.dart';
import 'package:moonhike/data/repositories/route_repository.dart';
import 'package:moonhike/domain/use_cases/get_routes_use_case.dart';
import 'package:moonhike/core/widgets/address_search_widget.dart';
import '../../core/utils/location_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonhike/presentation/screens/login.dart';

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

  final RouteRepository routeRepository = RouteRepository(RouteService('AIzaSyDNHOPdlWDOqsFiL9_UQCkg2fnlpyww6A4'));
  late GetRoutesUseCase getRoutesUseCase;

  _MapScreenState() {
    getRoutesUseCase = GetRoutesUseCase(routeRepository);
  }

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  // Establece la ubicación inicial
  void _setInitialLocation() async {
    try {
      Position position = await LocationUtils.getUserLocation();
      print("Ubicación actual: ${position.latitude}, ${position.longitude}");

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: 'Mi Ubicación'),
        ));
      });

      _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    } catch (e) {
      print('Error obteniendo la ubicación: $e');
      setState(() {
        _currentPosition = LatLng(25.6866, -100.3161);  // Monterrey por defecto
        _markers.add(Marker(
          markerId: MarkerId('defaultLocation'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: 'Ubicación por Defecto: Monterrey'),
        ));
      });

      _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  // Función para cerrar sesión
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();  // Cierra sesión en Firebase
    Navigator.pushReplacement( // Redirige al LoginPage
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Inicia la búsqueda de rutas
  Future<void> _startRoutes() async {
    if (_currentPosition == null || _selectedLocation == null) return;

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
  }

  // Selecciona una ruta de las disponibles
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer( // Menú desplegable
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
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
                _logout(); // Llama a la función de logout
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text('MoonHike')),
      body: Stack(
        children: [
          // Mapa de Google
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? LatLng(25.6866, -100.3161), // Monterrey por defecto
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
          // Barra de búsqueda de direcciones
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: AddressSearchWidget(
              onLocationSelected: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                  _markers.add(Marker(
                    markerId: MarkerId('selectedLocation'),
                    position: _selectedLocation!,
                    infoWindow: InfoWindow(title: 'Ubicación seleccionada'),
                  ));

                  _controller?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));

                  // Muestra el botón para iniciar rutas
                  _showStartRouteButton = true;
                });
              },
            ),
          ),
          // Botón para iniciar las rutas
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
          // Opciones de selección de rutas
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
    );
  }
}
