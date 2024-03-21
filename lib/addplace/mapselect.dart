import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSelectionPage extends StatefulWidget {
  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  late GoogleMapController _controller;
  LatLng? _selectedPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          _controller = controller;
        },
        onTap: (position) {
          setState(() {
            _selectedPosition = position;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(13.736717, 100.523186), // Default position
          zoom: 12,
        ),
        markers: _selectedPosition != null ? _createMarkers() : Set<Marker>(),
      ),
      floatingActionButton: _selectedPosition != null
          ? FloatingActionButton(
              onPressed: () {
                // Handle saving the selected position
                Navigator.pop(context, _selectedPosition);
              },
              child: Icon(Icons.save),
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.startFloat, // ตำแหน่ง FAB ที่กำหนด
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
