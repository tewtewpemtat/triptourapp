import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triptourapp/addplaceuser.dart';

class MapSelectionPage extends StatefulWidget {
  @override
  final String? tripUid;
  const MapSelectionPage({Key? key, this.tripUid}) : super(key: key);
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  late GoogleMapController _controller;
  LatLng? _selectedPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('กำหนดสถานที่'),
        automaticallyImplyLeading: false, // ไม่แสดงปุ่ม Back อัตโนมัติ
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPage(tripUid: widget.tripUid),
              ),
            ); // กลับไปที่หน้า AddPage
          },
        ),
      ),
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
