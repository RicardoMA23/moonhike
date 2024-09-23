import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/route_repository.dart';

class GetRoutesUseCase {
  final RouteRepository repository;

  GetRoutesUseCase(this.repository);

  Future<List<List<LatLng>>> execute(LatLng start, LatLng end) {
    return repository.fetchRoutes(start, end);
  }
}