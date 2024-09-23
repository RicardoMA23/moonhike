import 'package:flutter/material.dart';
import 'package:moonhike/presentation/widgets/address_search_widget.dart'; // Importa el widget de búsqueda
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // Para convertir direcciones en coordenadas
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _initialPosition = LatLng(40.712776, -74.005974); // Nueva York por defecto
  Set<Marker> _markers = {};
  LatLng? _selectedLocation; // Ubicación seleccionada por el usuario
  bool _showStartRouteButton = false; // Para mostrar el botón "Iniciar Ruta"

  // Función para buscar una dirección y mover el mapa
  void _onLocationSelected(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.clear(); // Limpiar otros marcadores
      _markers.add(Marker(
        markerId: MarkerId('selectedLocation'),
        position: location,
        infoWindow: InfoWindow(title: 'Destino Seleccionado'),
      ));
      _showStartRouteButton = true; // Mostrar botón al seleccionar ubicación
    });

    // Mover la cámara a la ubicación seleccionada
    _controller?.animateCamera(CameraUpdate.newLatLng(location));
  }

  // Obtener la ubicación actual del usuario
  Future<Position> _getUserLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  // Función para iniciar la ruta desde la ubicación actual
  void _startRoute() async {
    Position currentPosition = await _getUserLocation();
    LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

    // Aquí es donde calcularías y mostrarías la ruta desde currentLatLng a _selectedLocation
    print("Iniciando ruta desde: $currentLatLng hasta: $_selectedLocation");

    // Puedes usar la función que ya tienes para obtener la ruta peatonal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa con Mi Ubicación'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // Widget de búsqueda sobre el mapa
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: AddressSearchWidget(
              onLocationSelected: (location) {
                _onLocationSelected(location);
              },
            ),
          ),
          // Botón de iniciar ruta
          if (_showStartRouteButton)
            Positioned(
              bottom: 30,
              left: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: _startRoute,
                child: Text('Iniciar Ruta'),
              ),
            ),
        ],
      ),
    );
  }
}