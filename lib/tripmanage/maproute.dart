import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data'; // Add this import statement

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
  Timer? timer;
  late Uint8List markerIconBytes = Uint8List(0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (mounted) {
      _getDirections();
      _getMarkerIcon();
      timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
        _getCurrentLocation();
        _getDirections();
      });
      _getMarkerIcon();
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _getDirections() async {
    routeCoords.clear();
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
    if (mounted) {
      setState(() {
        widget.userLatitude = position.latitude;
        widget.userLongitude = position.longitude;
      });
    }

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.userLatitude, widget.userLongitude),
          zoom: 18,
        ),
      ),
    );
  }

  Future<void> _getMarkerIcon() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()
      ..color = Color.fromARGB(255, 26, 167, 249); // Set color to yellow
    final double radius = 32; // Increase circle radius

    canvas.drawCircle(Offset(radius, radius), radius,
        paint); // Increase circle size to 16 and draw in canvas

    // Draw white border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10 // Increase border thickness
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    final ui.Picture picture = pictureRecorder.endRecording();
    final img = await picture.toImage((radius * 2).toInt(),
        (radius * 2).toInt()); // Increase image size to match circle size
    final ByteData? byteData =
        await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null && mounted) {
      markerIconBytes = byteData.buffer.asUint8List();
    } else {
      throw 'Error converting image to bytes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('นำทาง'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.userLatitude, widget.userLongitude),
          zoom: 18,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId('user'),
            position: LatLng(widget.userLatitude, widget.userLongitude),
            icon: markerIconBytes.isNotEmpty
                ? BitmapDescriptor.fromBytes(markerIconBytes)
                : BitmapDescriptor.defaultMarker,
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
