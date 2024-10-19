import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:triptourapp/jointrip.dart';

class MapShowLocationPage extends StatefulWidget {
  final double? longitude;
  final double? latitude;
  const MapShowLocationPage({Key? key, this.longitude, this.latitude})
      : super(key: key);
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapShowLocationPage> {
  late LatLng _location;
  late CameraPosition _initialCameraPosition;
  late StreamSubscription<Position> _positionStreamSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize the location with the provided latitude and longitude
    _location = LatLng(widget.latitude ?? 0.0, widget.longitude ?? 0.0);

    // Set the initial camera position based on the provided location
    _initialCameraPosition = CameraPosition(
      target: _location,
      zoom: 12,
    );

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  void _getCurrentLocation() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        // Update location based on the current position
        _location = LatLng(widget.latitude ?? position.latitude,
            widget.longitude ?? position.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ตำแหน่งสถานที่'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => JoinTripPage()),
            // );
            Navigator.pop(context);
          },
        ),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {},
        initialCameraPosition: _initialCameraPosition,
        markers: _createMarkers(),
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return <Marker>{
      Marker(
        markerId: MarkerId('location_marker'),
        position: _location,
        infoWindow: InfoWindow(
          title: 'สถานที่',
        ),
      ),
    };
  }
}
