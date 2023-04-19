import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Demo',
      home: MapScreen(),
    );
  }
}


class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _polylineCoordinates = [];
  String _distance = '';
  String _duration = '';

  @override
  void initState() {
    super.initState();
    _getDirections();
  }

  Future<void> _getDirections() async {
    final LatLng origin =
    LatLng(48.8584, 2.2945); // Coordonnées de la Tour Eiffel
    final LatLng destination =
    LatLng(48.8738, 2.2950); // Coordonnées de l'Arc de Triomphe

    /*final origin = LatLng(9.669334, -13.558108);
    final destination = LatLng(9.651005, -13.603307);*/

    final String apiKey = 'AIzaSyAkxWY7GjJGgARoAbD1DZlpFNSaJPsQQrY';
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final http.Response response = await http.get(Uri.parse(apiUrl));
    final Map<String, dynamic> responseData = json.decode(response.body);
    final List<dynamic> routes = responseData['routes'];
    print(routes.length);
    final Map<String, dynamic> route = routes[0];
    final Map<String, dynamic> leg = route['legs'][0];
    final List<dynamic> steps = leg['steps'];
    _distance = leg['distance']['text'];
    _duration = leg['duration']['text'];

    List<LatLng> polylineCoordinates = [];

    for (int i = 0; i < steps.length; i++) {
      final Map<String, dynamic> step = steps[i];
      final Map<String, dynamic> startLocation = step['start_location'];
      final LatLng startPoint =
      LatLng(startLocation['lat'], startLocation['lng']);
      final Map<String, dynamic> endLocation = step['end_location'];
      final LatLng endPoint = LatLng(endLocation['lat'], endLocation['lng']);
      polylineCoordinates.add(startPoint);
      if (i == steps.length - 1) {
        polylineCoordinates.add(endPoint);
      }
    }
    setState(() {
      _polylineCoordinates = polylineCoordinates;
    });
    _fitMapToBounds();
  }

  void _fitMapToBounds() {
    if (_polylineCoordinates.isNotEmpty) {
      final LatLngBounds bounds = LatLngBounds.fromPoints(_polylineCoordinates);
      _mapController.fitBounds(bounds,
          options: FitBoundsOptions(padding: EdgeInsets.all(12.0)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directions'),
      ),
      body: Column(
        children: [
          Text('Distance: $_distance'),
          Text('Duration: $_duration'),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(0, 0),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylineCoordinates,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
