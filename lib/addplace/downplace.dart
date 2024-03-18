import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:triptourapp/addplace/slideplace.dart';
import 'package:triptourapp/requestlist.dart';

class DownPage extends StatefulWidget {
  final String? tripUid;

  const DownPage({Key? key, this.tripUid}) : super(key: key);

  @override
  _DownPageState createState() => _DownPageState();
}

class _DownPageState extends State<DownPage> {
  String? placeType;
  String? selectedOption;
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDgzISmUfbwWBHyrqyyma9AQQ_Tctimlt4');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFF0F0F0),
          padding: EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: SlidePlace(
                  tripUid: widget.tripUid,
                  onPlaceTypeChanged: (values) {
                    setState(() {
                      placeType =
                          values['placeType']; // เข้าถึงค่า placeType ใน values
                      selectedOption = values[
                          'selectedOption']; // เข้าถึงค่า selectedOption ใน values
                      _checkLocationPermission();
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {}, // Placeholder onTap function
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/userplan/userplan_image1.png',
                              width: 100.0,
                              height: 80.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        flex: 6,
                        child: Container(
                          margin: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ร้านกาแฟ WhiteCafe',
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 16,
                                  )),
                              SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: Color(0xFF1E30D7),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 1.0),
                                child: Text(
                                  'นนทบุรี',
                                  style: GoogleFonts.ibmPlexSansThai(
                                      fontSize: 11, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(top: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.add,
                                size: 24.0,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkLocationPermission() async {
    // Check if permission is already granted
    PermissionStatus status = await Permission.location.request();

    // Check if permission is granted
    if (status.isGranted) {
      // Permission is granted, proceed with fetching location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Check if selectedOption is "จากตำแหน่งใกล้ฉัน"
      if (selectedOption == "จากตำแหน่งใกล้ฉัน") {
        // Perform a nearby search for places using Google Places API
        await fetchNearLocation(position.latitude, position.longitude);
      }
    } else if (status.isDenied) {
      // Permission is denied, show a message to the user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Permission Denied'),
          content: Text('Please grant permission to access your location.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> fetchNearLocation(double latitude, double longitude) async {
    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Perform a nearby search for cafes using Google Places API
    PlacesSearchResponse response = await _places.searchNearbyWithRadius(
      Location(
        lat: position.latitude,
        lng: position.longitude,
      ),
      500, // Search radius in meters (adjust as needed)
      type: placeType,
      keyword: placeType, // Set the keyword to the placeType
    );

    // Iterate through the results and print the names of the cafes
    for (PlacesSearchResult result in response.results) {
      print(result.name);
    }
  }

  @override
  void dispose() {
    _places.dispose();
    super.dispose();
  }
}
