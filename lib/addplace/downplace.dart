import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'mapselect.dart'; // ต้องแก้ไขตามชื่อไฟล์ของหน้า MapSelectionPage จริงๆ
import 'package:permission_handler/permission_handler.dart';
import 'package:triptourapp/addplace/slideplace.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:triptourapp/requestlist.dart';

class Place {
  final String name;
  final String province;
  final String imageUrl;

  Place({required this.name, required this.province, required this.imageUrl});
}

class DownPage extends StatefulWidget {
  final String? tripUid;

  const DownPage({Key? key, this.tripUid}) : super(key: key);

  @override
  _DownPageState createState() => _DownPageState();
}

class _DownPageState extends State<DownPage> {
  String? placeType;
  String? selectedOption;
  LatLng? markedPosition;
  LatLng? selectedPosition = null;

  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDgzISmUfbwWBHyrqyyma9AQQ_Tctimlt4');
  List<Place> places = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    _handleSelectedOptionChange(selectedOption ?? "");
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.symmetric(
                            horizontal: 0.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    places[index].imageUrl,
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
                                    Text(
                                      places[index].name,
                                      style: GoogleFonts.ibmPlexSansThai(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        color: Color(0xFF1E30D7),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 1.0),
                                      child: Text(
                                        places[index].province,
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> fetchAddress(double latitude, double longitude) async {
    final apiKey = 'AIzaSyDgzISmUfbwWBHyrqyyma9AQQ_Tctimlt4';
    final apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        final addressComponents =
            results[0]['address_components'] as List<dynamic>;
        for (final component in addressComponents) {
          final types = component['types'] as List<dynamic>;
          if (types.contains('administrative_area_level_1')) {
            return component['long_name'] as String?;
          }
        }
      }
    }

    return null;
  }

  String? extractProvince(String address) {
    // Split address into parts using commas
    List<String> parts = address.split(',');

    // Province usually comes before the last part
    return parts.isNotEmpty ? parts[parts.length - 2].trim() : null;
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
        selectedPosition = null;
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

  void _handleSelectedOptionChange(String newOption) {
    setState(() {
      selectedOption = newOption;
      if (selectedOption == "จากตำแหน่งบนแผนที่" && selectedPosition == null) {
        _openMapSelectionPage();
      } else {
        fetchNearLocation(selectedPosition?.latitude ?? 0.0,
            selectedPosition?.longitude ?? 0.0);
      }
    });
  }

  void _openMapSelectionPage() async {
    selectedPosition = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(),
      ),
    );

    // เก็บตำแหน่งที่มาร์คบนแผนที่เมื่อผู้ใช้เลือก
    if (selectedPosition == null) {
      setState(() {
        this.markedPosition = selectedPosition;
      });
    }
  }

  Future<void> fetchNearLocation(double latitude, double longitude) async {
    // Perform a nearby search for places using Google Places API
    PlacesSearchResponse response = await _places.searchNearbyWithRadius(
      Location(
        lat: latitude,
        lng: longitude,
      ),
      100, // Search radius in meters (adjust as needed)
      type: placeType,
      keyword: placeType,
      // ตัวอย่างค้นหาร้านอาหาร
    );
    print(placeType);
    // Clear existing places
    places.clear();

    // Iterate through the results and add them to the list
    if (response.results != null) {
      // Iterate through the results and add them to the list
      for (PlacesSearchResult result in response.results!) {
        String? address = result.vicinity;
        String? province = extractProvince(address ?? '');
        places.add(Place(
          name: result.name ?? 'Unknown',
          province: province ?? 'Unknown', // ตัวอย่างการกำหนดชื่อจังหวัด
          imageUrl: result.photos != null && result.photos!.isNotEmpty
              ? _places.buildPhotoUrl(
                  photoReference: result.photos![0].photoReference!,
                  maxWidth: 400,
                )
              : 'https://via.placeholder.com/400', // URL ของรูปภาพตัวอย่าง
        ));
      }
    }

    // Update the UI
    setState(() {});
  }

  @override
  void dispose() {
    _places.dispose();
    super.dispose();
  }
}
