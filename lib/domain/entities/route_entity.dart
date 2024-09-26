/*La entidad Route puede tener propiedades como la lista de puntos (LatLng), la distancia, y la duración.
La entidad se encargará de representar estos datos de manera estructurada y será utilizada en toda la capa de dominio.*/

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteEntity {
  final List<LatLng> points;

  RouteEntity(this.points);
}