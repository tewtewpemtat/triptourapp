import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DirectionsScreen extends StatefulWidget {
  final double userLatitude; // พิกัดละติจูดปัจจุบันของผู้ใช้
  final double userLongitude; // พิกัดลองจิจูดปัจจุบันของผู้ใช้
  final double destinationLatitude; // พิกัดละติจูดของจุดนัดพบ
  final double destinationLongitude; // พิกัดลองจิจูดของจุดนัดพบ

  const DirectionsScreen({
    Key? key,
    required this.userLatitude,
    required this.userLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
  }) : super(key: key);

  @override
  _DirectionsScreenState createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  Timer? _timer;
  List<LatLng> _route = [];
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('นำทางไปยังจุดนัดพบ'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.userLatitude, widget.userLongitude),
          zoom: 12,
        ),
        onMapCreated: (controller) async {
          _startTimerToUpdatePosition();
          await _getRoute();
        },
        markers: {
          Marker(
            markerId: MarkerId('destination'),
            position:
                LatLng(widget.destinationLatitude, widget.destinationLongitude),
            infoWindow: InfoWindow(
              title: 'จุดนัดพบ',
            ),
          ),
          Marker(
            markerId: MarkerId('userLocation'),
            position: LatLng(widget.userLatitude, widget.userLongitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(
              title: 'ตำแหน่งปัจจุบันของคุณ',
            ),
          ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: _route,
            color: Colors.blue,
            width: 5,
          ),
        },
      ),
    );
  }

  void _startTimerToUpdatePosition() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateCurrentLocation();
    });
  }

  void _updateCurrentLocation() {
    setState(() {
      _route = [
        LatLng(widget.userLatitude, widget.userLongitude),
        LatLng(widget.destinationLatitude, widget.destinationLongitude),
      ];
    });
  }

  Future<List<LatLng>> fetchRoute(LatLng origin, LatLng destination) async {
    final String apiKey = 'AIzaSyDgzISmUfbwWBHyrqyyma9AQQ_Tctimlt4';
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<LatLng> points = [];

      decoded['routes'][0]['legs'][0]['steps'].forEach((step) {
        points.add(LatLng(
            step['start_location']['lat'], step['start_location']['lng']));
        points.add(
            LatLng(step['end_location']['lat'], step['end_location']['lng']));
      });

      return points;
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<void> _getRoute() async {
    try {
      List<LatLng> route = await fetchRoute(
          LatLng(widget.userLatitude, widget.userLongitude),
          LatLng(widget.destinationLatitude, widget.destinationLongitude));
      setState(() {
        _route = route;
      });
    } catch (e) {
      print('Error fetching route: $e');
    }
  }
}
