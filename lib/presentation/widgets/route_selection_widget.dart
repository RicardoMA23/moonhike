import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteSelectionWidget extends StatelessWidget {
  final List<List<LatLng>> routes;
  final Function(int) onRouteSelected;

  RouteSelectionWidget({required this.routes, required this.onRouteSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(routes.length, (index) {
        return ListTile(
          title: Text('Ruta ${index + 1}'),
          onTap: () => onRouteSelected(index),
        );
      }),
    );
  }
}