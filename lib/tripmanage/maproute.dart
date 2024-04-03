import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  double userLatitude;
  double userLongitude;
  final double placeLatitude;
  final double placeLongitude;

  MapScreen({
    required this.userLatitude,
    required this.userLongitude,
    required this.placeLatitude,
    required this.placeLongitude,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  late List<LatLng> routeCoords = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (mounted) {
      _getDirections();
    }
  }

  Future<void> _getDirections() async {
    String apiUrl = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${widget.userLatitude},${widget.userLongitude}&"
        "destination=${widget.placeLatitude},${widget.placeLongitude}&"
        "key=AIzaSyDgzISmUfbwWBHyrqyyma9AQQ_Tctimlt4";

    final response = await http.get(Uri.parse(apiUrl));
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData["status"] == "OK") {
      List<dynamic> routes = responseData["routes"];
      Map<String, dynamic> route = routes[0];
      List<dynamic> legs = route["legs"];
      Map<String, dynamic> leg = legs[0];
      List<dynamic> steps = leg["steps"];

      steps.forEach((step) {
        Map<String, dynamic> polyline = step["polyline"];
        String points = polyline["points"];
        _convertToLatLng(_decodePoly(points));
      });
    }
  }

  void _convertToLatLng(List points) {
    if (mounted) {
      // เช็คว่า State ยังคงถูก mount หรือไม่ก่อนเรียก setState()
      points.forEach((point) {
        routeCoords.add(LatLng(point[0], point[1]));
      });
      setState(() {
        routeCoords = routeCoords;
      });
    }
  }

  List _decodePoly(String encoded) {
    List<int> encodedPoints = encoded.codeUnits;
    int len = encodedPoints.length;
    int index = 0;
    List<dynamic> latLngs = [];
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encodedPoints[index++] - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encodedPoints[index++] - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      latLngs.add([lat / 1E5, lng / 1E5]);
    }
    return latLngs;
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      widget.userLatitude = position.latitude;
      widget.userLongitude = position.longitude;
    });

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.userLatitude, widget.userLongitude),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.userLatitude, widget.userLongitude),
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId('user'),
            position: LatLng(widget.userLatitude, widget.userLongitude),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: LatLng(widget.placeLatitude, widget.placeLongitude),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.blue,
            points: routeCoords,
          ),
        },
      ),
    );
  }
}
