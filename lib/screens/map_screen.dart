import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled2/widgets/database_helper.dart';
import 'package:untitled2/widgets/Iperf3Server.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static final LatLng _usmCenter = LatLng(5.3560, 100.3014);

  // Define the bounds using the new coordinates
  static final LatLngBounds _usmBounds = LatLngBounds(
    southwest: LatLng(5.352745, 100.292406), // Bottom left corner
    northeast: LatLng(5.363015, 100.310781), // Top right corner
  );

  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _hasShownWarning = false; // Flag to track if the warning has been shown
  double? _distanceToUsm; // Variable to store the distance
  Polyline? _lineToUsm; // Polyline for the line to USM
  List<Iperf3Server> _iperf3Servers = [];

  @override
  void initState() {
    super.initState();
    _loadIperf3Servers();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _loadIperf3Servers() async {
    final dbHelper = DatabaseHelper();
    final servers = await dbHelper.getIperf3Servers();
    setState(() {
      _iperf3Servers = servers;
    });
  }

  void _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
          final latLng = LatLng(position.latitude, position.longitude);
          setState(() {
            _currentPosition = latLng;
            _distanceToUsm = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              _usmCenter.latitude,
              _usmCenter.longitude,
            );
            _lineToUsm = Polyline(
              polylineId: PolylineId('lineToUsm'),
              points: [latLng, _usmCenter],
              color: Colors.blue.withOpacity(0.5), // Less transparent line
              width: 5,
              patterns: [PatternItem.dot, PatternItem.gap(10)], // Dotted line
            );
          });
          _checkIfWithinUSM(latLng);
        });
  }

  void _checkIfWithinUSM(LatLng position) {
    if (!_usmBounds.contains(position) && !_hasShownWarning) {
      _showWarningDialog();
      _hasShownWarning = true; // Set the flag to true
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text('You are out of the USM area.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _usmCenter,
              zoom: 15,
            ),
            mapType: MapType.satellite, // Set map type to satellite to remove street names
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _mapController!.moveCamera(
                CameraUpdate.newLatLngBounds(_usmBounds, 0),
              );
            },
            minMaxZoomPreference: MinMaxZoomPreference(5, 20), // Adjust minZoom value to allow further zoom out
            polylines: _lineToUsm != null ? {_lineToUsm!} : {},
            polygons: {
              Polygon(
                polygonId: PolygonId('usmArea'),
                points: [
                  LatLng(5.357625, 100.288211),
                  LatLng(5.355318, 100.288480),
                  LatLng(5.352745, 100.292406),
                  LatLng(5.355179, 100.293104),
                  LatLng(5.353228, 100.302268),
                  LatLng(5.355718, 100.308865),
                  LatLng(5.363015, 100.310781),
                  LatLng(5.361988, 100.300600),
                  LatLng(5.358785, 100.300190),
                  LatLng(5.357985, 100.296989),
                  LatLng(5.357571, 100.292760),
                  LatLng(5.357625, 100.288211), // Closing the polygon loop
                ],
                strokeColor: Colors.yellow,
                strokeWidth: 2,
                fillColor: Colors.yellow.withOpacity(0.2),
              ),
            },
            markers: _iperf3Servers.map((server) {
              return Marker(
                markerId: MarkerId(server.id.toString()),
                position: LatLng(server.latitude, server.longitude),
                infoWindow: InfoWindow(title: server.name),
              );
            }).toSet(),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _distanceToUsm != null
                      ? 'Distance to USM: ${(_distanceToUsm! / 1000).toStringAsFixed(2)} km'
                      : 'Calculating distance...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

