import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

void main() => runApp(MyApp());

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
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  List<LatLng> polylineCoordinates = [];
  String distance = '';
  String duration = '';

  Future<void> getDirections() async {
    final origin = Uri.encodeComponent(fromController.text);
    final destination = Uri.encodeComponent(toController.text);

    final response = await http
        .get(Uri.parse("https://maps.googleapis.com/maps/api/directions/json?"
        "origin=$origin"
        "&destination=$destination"
        "&key=AIzaSyAkxWY7GjJGgARoAbD1DZlpFNSaJPsQQrY"));

    final data = json.decode(response.body);
    final routes = data['routes'];
    print(routes);
    final legs = routes[0]['legs'];
    final distanceText = legs[0]['distance']['text'];
    final durationText = legs[0]['duration']['text'];
    final steps = legs[0]['steps'];

    setState(() {
      polylineCoordinates.clear();
      distance = distanceText;
      duration = durationText;
    });

    for (var i = 0; i < steps.length; i++) {
      final polyline = steps[i]['polyline'];
      final coords = PolylinePoints().decodePolyline(polyline['points']);
      setState(() {
        polylineCoordinates.addAll(
            coords.map((coord) => LatLng(coord.latitude, coord.longitude)));
      });
    }

    mapController.fitBounds(
      LatLngBounds(
        LatLng(
          polylineCoordinates.first.latitude,
          polylineCoordinates.first.longitude,
        ),
        LatLng(
          polylineCoordinates.last.latitude,
          polylineCoordinates.last.longitude,
        ),
      ),
      options: FitBoundsOptions(
        padding: EdgeInsets.all(50.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Map Demo'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: fromController,
                    decoration: InputDecoration(
                      hintText: 'From',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: toController,
                    decoration: InputDecoration(
                      hintText: 'To',
                    ),
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: getDirections,
            child: Text('Get Directions'),
          ),
          if (polylineCoordinates.isNotEmpty)
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  center: polylineCoordinates.first,
                  zoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: polylineCoordinates,
                        color: Colors.red,
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (distance.isNotEmpty && duration.isNotEmpty)
            Text('Distance: $distance\nDuration: $duration'),
        ],
      ),
    );
  }
}
