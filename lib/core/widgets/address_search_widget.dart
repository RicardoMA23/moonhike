import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressSearchWidget extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  AddressSearchWidget({required this.onLocationSelected});

  @override
  _AddressSearchWidgetState createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends State<AddressSearchWidget> {
  TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;

  void _getSuggestions(String input) async {
    final String apiKey = 'AIzaSyDNHOPdlWDOqsFiL9_UQCkg2fnlpyww6A4'; // Reemplaza con tu API key de Places
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);
    setState(() {
      _suggestions = json['predictions'];
    });
  }

  void _getLatLngFromPlaceId(String placeId) async {
    final String apiKey = 'AIzaSyDNHOPdlWDOqsFiL9_UQCkg2fnlpyww6A4'; // Reemplaza con tu API key de Places
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);
    var location = json['result']['geometry']['location'];
    LatLng selectedLocation = LatLng(location['lat'], location['lng']);

    widget.onLocationSelected(selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 5.0,
          shadowColor: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Buscar una dirección...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _getSuggestions(value);
              } else {
                setState(() {
                  _suggestions = [];
                });
              }
            },
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestions[index]['description']),
                  onTap: () {
                    String placeId = _suggestions[index]['place_id'];
                    _controller.text = _suggestions[index]['description'];
                    setState(() {
                      _suggestions = [];
                    });
                    _getLatLngFromPlaceId(placeId);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}