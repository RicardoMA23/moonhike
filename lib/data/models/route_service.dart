import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteService {
  final String apiKey;

  RouteService(this.apiKey);

  // Función para obtener las rutas entre dos ubicaciones
  Future<List<List<LatLng>>> getRoutes(LatLng origin, LatLng destination) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=walking&alternatives=true&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          List<List<LatLng>> routes = [];

          for (var route in data['routes']) {
            String polylinePoints = route['overview_polyline']['points'];
            routes.add(_decodePolyline(polylinePoints));
          }

          return routes; // Lista de rutas decodificadas
        } else {
          print("No se encontraron rutas.");
          return [];
        }
      } else {
        print("Error en la solicitud: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print('Error al obtener las rutas: $e');
      return [];
    }
  }

  // Función para decodificar la polyline en puntos LatLng
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}