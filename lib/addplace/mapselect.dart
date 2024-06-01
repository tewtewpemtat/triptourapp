import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triptourapp/addplace.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class MapSelectionPage extends StatefulWidget {
  final String? tripUid;
  const MapSelectionPage({Key? key, this.tripUid}) : super(key: key);
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  LatLng? _selectedPosition;
  late StreamSubscription<Position> _positionStreamSubscription;
  double userLatitude = 0.0;
  double userLongitude = 0.0;

  @override
  void initState() {
    super.initState();
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
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('กำหนดสถานที่'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddPage(tripUid: widget.tripUid),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<Position>(
        stream: Geolocator.getPositionStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return GoogleMap(
            onMapCreated: (controller) {},
            onTap: (position) {
              setState(() {
                _selectedPosition = position;
              });
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(userLatitude, userLongitude),
              zoom: 12,
            ),
            markers:
                _selectedPosition != null ? _createMarkers() : Set<Marker>(),
          );
        },
      ),
      floatingActionButton: _selectedPosition != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, _selectedPosition);
              },
              child: Icon(Icons.save),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Set<Marker> _createMarkers() {
    return <Marker>{
      Marker(
        markerId: MarkerId('selected_position'),
        position: _selectedPosition!,
        draggable: false,
      ),
    };
  }
}
