import 'package:flutter/material.dart';
import 'package:moonhike/presentation/widgets/address_search_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moonhike/data/models/route_service.dart'; // Importar el servicio de rutas

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
  Set<Polyline> _polylines = {}; // Para dibujar las rutas

  // Instancia del servicio de rutas
  RouteService routeService = RouteService('AIzaSyDNHOPdlWDOqsFiL9_UQCkg2fnlpyww6A4'); // Coloca tu API Key

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Los servicios de ubicación están desactivados');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permiso de ubicación denegado permanentemente');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _setInitialLocation() async {
    try {
      Position currentPosition = await _getUserLocation();
      LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

      setState(() {
        _currentPosition = currentLatLng;
        _markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: currentLatLng,
          infoWindow: InfoWindow(title: 'Mi Ubicación'),
        ));
      });

      _controller?.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    } catch (e) {
      print('Error obteniendo la ubicación: $e');
    }
  }

  void _onLocationSelected(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.add(Marker(
        markerId: MarkerId('selectedLocation'),
        position: location,
        infoWindow: InfoWindow(title: 'Destino Seleccionado'),
      ));
      _showStartRouteButton = true;
    });

    _controller?.animateCamera(CameraUpdate.newLatLng(location));
  }

  Future<void> _startRoutes() async {
    if (_currentPosition == null || _selectedLocation == null) {
      print("No se puede iniciar la ruta sin una ubicación actual o destino");
      return;
    }

    // Llamamos a la función getRoutes desde el servicio de rutas
    List<List<LatLng>> routes = await routeService.getRoutes(_currentPosition!, _selectedLocation!);

    if (routes.isNotEmpty) {
      // Limpiamos las polylines existentes
      setState(() {
        _polylines.clear();
      });

      // Dibujamos cada ruta con un color diferente
      for (int i = 0; i < routes.length; i++) {
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId('route_$i'),
            points: routes[i],
            color: i == 0 ? Colors.blue : Colors.grey, // Primera ruta (más rápida) en azul, las demás en gris
            width: 5,
          ));
        });
      }

      // Mover la cámara para mostrar toda la ruta
      LatLngBounds bounds = _getBoundsFromLatLngList(routes.expand((route) => route).toList());
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  // Función para obtener los límites de la cámara con base en los puntos LatLng
  LatLngBounds _getBoundsFromLatLngList(List<LatLng> list) {
    double southWestLat = list.map((e) => e.latitude).reduce((value, element) => value < element ? value : element);
    double southWestLng = list.map((e) => e.longitude).reduce((value, element) => value < element ? value : element);
    double northEastLat = list.map((e) => e.latitude).reduce((value, element) => value > element ? value : element);
    double northEastLng = list.map((e) => e.longitude).reduce((value, element) => value > element ? value : element);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
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
              target: _currentPosition ?? LatLng(40.712776, -74.005974),
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              if (_currentPosition != null) {
                _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
              }
            },
            markers: _markers,
            polylines: _polylines, // Añadimos las polylines para las rutas
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
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
          if (_showStartRouteButton)
            Positioned(
              bottom: 30,
              left: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: _startRoutes,
                child: Text('Iniciar Rutas'),
              ),
            ),
        ],
      ),
    );
  }
}