import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapPage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController _mapController = MapController();
  late Position _currentPosition;
  final origine = LatLng(9.669334, -13.558108);
  final destination = LatLng(9.651005, -13.603307);

  /*var url = Uri.parse("https://maps.googleapis.com/maps/api/directions/json?"
      "origin=9.669334,-13.558108"
      "&destination=9.651005,-13.603307}"
      "&key=YOUR_API_KEY");
 final response =  http.get(url) as http.Response;
  if (response.statusCode == 200) {
  String data = response.body;
  var decodedData = jsonDecode(data);
  return decodedData;
  } else {
    //return 'failed';
  }


  final data = json.decode(response.body);
  final routes = data['routes'];
  final legs = routes[0]['legs'];
  final distance = legs[0]['distance']['value'];
  final duration = legs[0]['duration']['value'];
  final steps = legs[0]['steps'];*/

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlutterMap(
          options: MapOptions(
            //center: LatLng(_currentPosition.latitude, _currentPosition.longitude),
            center: LatLng(9.651005, -13.603307),
            zoom: 13,
          ),
          nonRotatedChildren: [
            AttributionWidget.defaultWidget(
              source: 'OpenStreetMap contributors',
              onSourceTapped: null,
            ),
          ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 25,
                  height: 25,
                  point: LatLng(9.651005, -13.603307),
                  builder: (ctx) => Container(
                    child: Icon(Icons.location_on),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
