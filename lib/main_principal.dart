import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleMapController? mapController; //controller for Google map
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyAkxWY7GjJGgARoAbD1DZlpFNSaJPsQQrY";

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  final startLocation = const LatLng(9.669334, -13.558108);
  final endLocation = const LatLng(9.611226, -13.645598);
  var troncons = 0;

  String? selectedDeparture;
  String? selectedArrival;

  final List<String> departOptions = ['Option 1', 'Option 2', 'Option 3'];
  final List<String> arrivalOptions = ['Option A', 'Option B', 'Option C'];

  List<LatLng> waypoints = [
    LatLng(9.680500, -13.579675), // second waypoint
    LatLng(9.639360, -13.615796), // third waypoint
  ];

  @override
  void initState() {
    markers.add(Marker(
      //add start location marker
      markerId: MarkerId(startLocation.toString()),
      position: startLocation, //position of marker
      infoWindow: const InfoWindow(
        //popup info
        title: 'Starting Point ',
        snippet: 'Start Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    markers.add(Marker(
      //add distination location marker
      markerId: MarkerId(endLocation.toString()),
      position: endLocation, //position of marker
      infoWindow: const InfoWindow(
        //popup info
        title: 'Destination Point ',
        snippet: 'Destination Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    getDirections(); //fetch direction polylines from Google API

    super.initState();
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    // add start location and end location to the waypoints list
    List<LatLng> allWaypoints = [startLocation, ...waypoints, endLocation];

    // fetch the route between each pair of adjacent waypoints
    for (int i = 0; i < allWaypoints.length - 1; i++) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(allWaypoints[i].latitude, allWaypoints[i].longitude),
        PointLatLng(allWaypoints[i + 1].latitude, allWaypoints[i + 1].longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print(result.errorMessage);
      }

      // add a marker for the current waypoint
      markers.add(Marker(
        markerId: MarkerId(allWaypoints[i].toString()),
        position: allWaypoints[i],
        infoWindow: InfoWindow(
          title: 'Waypoint ${i + 1}',
          snippet: 'Waypoint Marker',
        ),
      ));
    }
    troncons = markers.length - 2;
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Guinée Trajets"),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: Column(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Départ'),
                  DropdownButton<String>(
                    value: selectedDeparture,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDeparture = newValue;
                      });
                    },
                    items: departOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.0),
                  Text('Arrivée'),
                  DropdownButton<String>(
                    value: selectedArrival,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedArrival = newValue;
                      });
                    },
                    items: arrivalOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GoogleMap(
                //Map widget from google_maps_flutter package
                zoomGesturesEnabled: true, //enable Zoom in, out on map
                initialCameraPosition: CameraPosition(
                  //innital position in map
                  target: startLocation, //initial position
                  zoom: 16.0, //initial zoom level
                ),
                markers: markers, //markers to show on map
                polylines: Set<Polyline>.of(polylines.values), //polylines
                mapType: MapType.normal, //map type
                onMapCreated: (controller) {
                  //method called when map is created
                  setState(() {
                    mapController = controller;
                  });
                },
              ),
            ),
          ],
        ));
  }
}
