import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_service.dart';

class RouteRepository {
  final RouteService routeService;

  RouteRepository(this.routeService);

  Future<List<List<LatLng>>> fetchRoutes(LatLng start, LatLng end) {
    return routeService.getRoutes(start, end);
  }
}