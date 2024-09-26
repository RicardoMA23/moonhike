/*Este archivo contiene el caso de uso para obtener las rutas. Aquí es donde se gestiona la lógica de la aplicación
para obtener las rutas desde el repositorio.*/

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/route_repository.dart';

class GetRoutesUseCase {
  final RouteRepository repository;

  GetRoutesUseCase(this.repository);

  Future<List<List<LatLng>>> execute(LatLng start, LatLng end) {
    return repository.fetchRoutes(start, end);
  }
}