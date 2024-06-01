import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triptourapp/tripmanage.dart';

class MapSelectionPage extends StatefulWidget {
  final String? tripUid;
  final double? placelat;
  final double? placelong;
  const MapSelectionPage(
      {Key? key, this.tripUid, this.placelat, this.placelong})
      : super(key: key);
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  LatLng? _selectedPosition;

  late Future<void> _initialCameraPositionFuture;

  @override
  void initState() {
    super.initState();
    _initialCameraPositionFuture = _getInitialCameraPosition();
    print("asadadadadadaadadaadadadada ${widget.placelat} ${widget.placelong}");
  }

  Future<void> _getInitialCameraPosition() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate some async task
    return;
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripmanagePage(tripUid: widget.tripUid),
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initialCameraPositionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return _buildMap();
          }
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

  Widget _buildMap() {
    Set<Marker> markers = {};
    markers.add(
      Marker(
        markerId: MarkerId('user_location'),
        position: LatLng(
            widget.placelat ?? 13.136717, widget.placelong ?? 107.123186),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        // You can customize the icon further if needed
        infoWindow: InfoWindow(
          title: 'ตำแหน่งสถานที่',
        ),
      ),
    );

    if (_selectedPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('selected_position'),
          position: _selectedPosition!,
          draggable: false,
        ),
      );
    }
    return GoogleMap(
      onMapCreated: (controller) {},
      onTap: (position) {
        setState(() {
          _selectedPosition = position;
          print(widget.placelat);
        });
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(
            widget.placelat ?? 13.136717, widget.placelong ?? 107.123186),
        zoom: 13,
      ),
      markers: Set<Marker>.from(markers),
    );
  }
}
