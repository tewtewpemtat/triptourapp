import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:triptourapp/addplace/mapselectown.dart';
import 'package:triptourapp/requestplace.dart';
import 'mapselect.dart'; // ต้องแก้ไขตามชื่อไฟล์ของหน้า MapSelectionPage จริงๆ
import 'package:permission_handler/permission_handler.dart';
import 'package:triptourapp/addplace/slideplace.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:triptourapp/requestlist.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

class Place {
  final String name;
  final String province;
  final String imageUrl;
  final double latitude; // Add latitude field
  final double longitude;
  final String? placeprovince;
// Add longitude field
  Place({
    required this.name,
    required this.province,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.placeprovince,
  });
}

class DownPage extends StatefulWidget {
  final String? tripUid;
  final String? query;
  const DownPage({Key? key, this.tripUid, this.query}) : super(key: key);

  @override
  _DownPageState createState() => _DownPageState();
}

class _DownPageState extends State<DownPage> {
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  String? placeType;
  String? selectedOption;
  LatLng? markedPosition;
  LatLng? selectedPosition = null;
  bool isLoading = false;
  int searchRadius = 0;
  int searchRadius2 = 0;
  bool search = false; // ค่าเริ่มต้นของระยะห่างในการค้นหา
  @override
  void initState() {
    super.initState();
    if (widget.query != null) {
      searchPlaces(widget.query!);
    }
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                onSubmitted: (value) {
                  Fluttertoast.showToast(
                    msg: "กำลังค้นหาสถานที่..",
                    toastLength: Toast.LENGTH_LONG,
                  );
                  searchPlaces(value);
                },
                decoration: InputDecoration(
                  hintText: 'ค้นหาสถานที่',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 5, horizontal: 15), // ปรับขนาดของช่องค้นหา
                  prefixIcon: Icon(Icons.search,
                      color: const Color.fromARGB(255, 21, 21, 21)),
                ),
              ),
            ),
            SizedBox(height: 10),
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
                    _checkLocationPermission(selectedOption ?? "");
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
                    try {
                      return Container(
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
                              child: GestureDetector(
                                onTap: () {
                                  Fluttertoast.showToast(
                                    msg: "กำลังเพิ่มสถานที่...",
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                  addPlaceToFirestore(
                                      userUid: uid ??
                                          '', // Use the current user's UID
                                      placeTripId: widget.tripUid ??
                                          '', // Use the trip UID from the widget property
                                      placeName: places[index]
                                          .name, // Use the name of the place
                                      placePicUrl: places[index]
                                          .imageUrl, // Use the image URL of the place
                                      placeAddress: places[index]
                                          .province, // You can leave this empty or provide an address if available
                                      placeStart:
                                          '', // You can leave this empty or provide a start time if available
                                      placeTimeEnd:
                                          null, // You can leave this empty or provide an end time if available
                                      placeTimeStart:
                                          null, // You can leave this empty or provide a start time if available
                                      placeLatitude: places[index]
                                          .latitude, // Use latitude field
                                      placeLongitude: places[index]
                                          .longitude, // Use longitude field

                                      // Use the location of the place
                                      placeWhoGo: [uid ?? ''],
                                      placeStatus: 'Added',
                                      placeProvince:
                                          places[index].placeprovince ?? '',
                                      placeAdd: 'No' ?? '',
                                      placeRun: 'Start' ??
                                          '' // Initially, no one goes to this place, so it's an empty array
                                      );
                                },
                                child: Icon(
                                  Icons.add,
                                  size: 24.0,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "ไม่พบสถานที่",
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String generateRandomNumber() {
    Random random = Random();
    int randomNumber = random.nextInt(999999999 - 100000000) + 100000000;
    return randomNumber.toString();
  }

  Future<void> addPlaceToFirestore({
    required String userUid,
    required String placeTripId,
    required String placeName,
    required String placePicUrl,
    required String placeAddress,
    required String placeStart,
    required DateTime? placeTimeEnd, // เปลี่ยนให้เป็น DateTime?
    required DateTime? placeTimeStart, // เปลี่ยนให้เป็น DateTime?
    required double placeLatitude, // Change parameter name to placeLatitude
    required double placeLongitude, // Change parameter name to placeLongitude
    required List<String> placeWhoGo,
    required String placeStatus,
    required String placeProvince,
    required String placeAdd,
    required String placeRun,
  }) async {
    try {
      // Check if the place already exists in the trip
      QuerySnapshot tripPlaces = await FirebaseFirestore.instance
          .collection('places')
          .where('placetripid', isEqualTo: placeTripId)
          .where('placename', isEqualTo: placeName)
          .where('placeLatitude', isEqualTo: placeLatitude) // Check latitude
          .where('placeLongitude', isEqualTo: placeLongitude)
// Check longitude
          .get();

      // If the place already exists in the trip, do not add it again
      if (tripPlaces.docs.isNotEmpty) {
        // Place already exists in the trip
        DocumentSnapshot existingPlace = tripPlaces.docs.first;
        String existingPlaceId = existingPlace.id;
        String existingPlaceStatus = existingPlace.get('placestatus');

        if (existingPlaceStatus == 'Wait') {
          // Update the place status to 'Added'
          await FirebaseFirestore.instance
              .collection('places')
              .doc(existingPlaceId)
              .update({'placestatus': 'Added'});

          Fluttertoast.showToast(msg: 'เพิ่มสถานที่สำเร็จ');
        } else {
          // Place exists in the trip with a status other than 'Wait'
          Fluttertoast.showToast(msg: 'มีสถานที่นี้อยู่บนทริปเเล้ว');
        }
        return;
      }
      final randomImg = generateRandomNumber();

      // Upload image to Firebase Storage
      Reference storageReference = FirebaseStorage.instance.ref().child(
            'trip/places/profilepic/$placeTripId/$placeName$randomImg.jpg',
          );
      UploadTask uploadTask = storageReference.putData(
        await http.get(Uri.parse(placePicUrl)).then((res) => res.bodyBytes),
      );
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

      // Add place data to Firestore
      await FirebaseFirestore.instance.collection('places').doc().set({
        'useruid': userUid,
        'placetripid': placeTripId,
        'placename': placeName,
        'placepicUrl': downloadUrl,
        'placeaddress': placeAddress,
        'placestart': placeStart,
        'placetimestart': placeTimeStart,
        'placetimeend': placeTimeEnd,
        'placeLatitude': placeLatitude, // แก้เป็น placeLatitude
        'placeLongitude':
            placeLongitude, // แก้เป็น placeLongitudeUse new latitude and longitude fields
        'placewhogo': placeWhoGo,
        'placestatus': placeStatus,
        'placeprovince': placeProvince,
        'placeadd': placeAdd,
        'placerun': placeRun
      });

      // Notify the user that the place has been successfully added
      Fluttertoast.showToast(msg: 'เพิ่มสถานที่สำเร็จ');
    } catch (error) {
      print('Error adding place to Firestore: $error');
    }
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
        final addressComponents = results[0]['formatted_address'];
        return addressComponents as String?;
      }
    }

    return null;
  }

  Future<String?> fetchProvinceFromAddress(String address) async {
    try {
      List<String> parts = address.split(',');
      // ถ้ามีส่วนที่อยู่จังหวัด
      if (parts.length >= 2) {
        // นำส่วนที่อยู่จังหวัดมาใช้งาน
        String provincePart = parts[parts.length - 2].trim();
        return provincePart;
      } else {
        // ถ้าไม่มีส่วนที่อยู่จังหวัด ให้คืนค่า null
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'ไม่พบสถานที่');
    }
  }

  Future<void> searchPlaces(String query) async {
    try {
      PlacesSearchResponse response = await _places.searchByText(query);
      if (response.isOkay) {
        // Clear existing places first
        places.clear();
        int maxResults = 10;
        if (response.results != null) {
          // Iterate through the results and add them to the list
          for (int i = 0; i < response.results!.length && i < maxResults; i++) {
            PlacesSearchResult result = response.results![i];
            PlacesDetailsResponse detailsResponse =
                await _places.getDetailsByPlaceId(result.placeId!);
            String? placeAddress = detailsResponse.result?.formattedAddress;
            String? province =
                await fetchProvinceFromAddress(placeAddress ?? '');
            LatLng position = LatLng(
              detailsResponse.result?.geometry?.location.lat ?? 0.0,
              detailsResponse.result?.geometry?.location.lng ?? 0.0,
            );
            String? placeProvince = await getProvinceFromCoordinates(position);
            double latitude =
                detailsResponse.result?.geometry?.location.lat ?? 0.0;
            double longitude =
                detailsResponse.result?.geometry?.location.lng ?? 0.0;
            places.add(Place(
                name: result.name ?? 'Unknown',
                province: province ?? 'Unknown',
                imageUrl: result.photos != null && result.photos!.isNotEmpty
                    ? _places.buildPhotoUrl(
                        photoReference: result.photos![0].photoReference!,
                        maxWidth: 400,
                      )
                    : 'https://via.placeholder.com/400',
                latitude:
                    latitude, // เพิ่มพารามิเตอร์ latitude ให้กับอ็อบเจกต์ Place
                longitude: longitude,
                placeprovince: placeProvince));
          }
        }
        setState(() {}); // Update UI
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'ไม่พบสถานที่');
    }
  }

  Future<String?> getProvinceFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return placemark
            .administrativeArea; // หรือจะใช้ .subAdministrativeArea ก็ได้
      } else {
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'ไม่พบสถานที่');
    }
  }
// Function to fetch province from address

  Future<void> _checkLocationPermission(String newOption) async {
    // Check if permission is already granted
    PermissionStatus status = await Permission.location.request();

    // Check if permission is granted
    if (status.isGranted) {
      // Permission is granted, proceed with fetching location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Check if selectedOption is "จากตำแหน่งใกล้ฉัน"
      setState(() {
        selectedOption = newOption;
        if (selectedOption == "จากตำแหน่งใกล้ฉัน") {
          search = true;
          searchRadius2 = 0;
          if (searchRadius == 0) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('ระยะห่างในการค้นหา (เมตร)'),
                content: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ระยะห่างในการค้นหา (เมตร)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchRadius = int.tryParse(value) ?? 0;
                    });
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      fetchNearLocation(position.latitude, position.longitude);
                    },
                    child: Text('ตกลง'),
                  ),
                ],
              ),
            );
          } else {
            fetchNearLocation(position.latitude, position.longitude);
            search = true;
            selectedPosition = null;
            searchRadius2 = 0;
            Fluttertoast.showToast(
              msg: "กำลังโหลดสถานที่...",
              toastLength: Toast.LENGTH_LONG,
            );
          }
        } else if (selectedOption == "จากตำแหน่งบนแผนที่" &&
            selectedPosition == null) {
          search = false;
          searchRadius = 0;
          _openMapSelectionPage();
        } else if (selectedOption == "จากตำแหน่งบนแผนที่" &&
            selectedPosition != null) {
          search = false;
          searchRadius = 0;
          if (searchRadius2 == 0) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('ระยะห่างในการค้นหา (เมตร)'),
                content: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ระยะห่างในการค้นหา (เมตร)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchRadius2 = int.tryParse(value) ?? 0;
                    });
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // เมื่อผู้ใช้ป้อนระยะห่างในการค้นหาแล้วให้ดึงสถานที่ใกล้เคียงตามระยะที่ระบุ
                      fetchNearLocation(selectedPosition?.latitude ?? 0.0,
                          selectedPosition?.longitude ?? 0.0);
                      Fluttertoast.showToast(
                        msg: "กำลังโหลดสถานที่..",
                        toastLength: Toast.LENGTH_LONG,
                      );
                    },
                    child: Text('ตกลง'),
                  ),
                ],
              ),
            );
          } else {
            fetchNearLocation(selectedPosition?.latitude ?? 0.0,
                selectedPosition?.longitude ?? 0.0);
            Fluttertoast.showToast(
              msg: "กำลังโหลดสถานที่..",
              toastLength: Toast.LENGTH_LONG,
            );
          }
        } else if (selectedOption == "จากคำร้องขอสถานที่") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestPage(tripUid: widget.tripUid),
            ),
          );
        } else if (selectedOption == "เพิ่มสถานที่เอง") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MapSelectionOwnPage(tripUid: widget.tripUid),
            ),
          );
        }
      });
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

  // void _handleSelectedOptionChange(String newOption) {
  //   setState(() {
  //     selectedOption = newOption;
  //     if (selectedOption == "จากตำแหน่งบนแผนที่" && selectedPosition == null) {
  //       _openMapSelectionPage();
  //     } else if (selectedOption == "จากคำร้องขอสถานที่") {
  //       // Navigate push ไปยังหน้า RequestPage พร้อมส่ง tripUid มาด้วย
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => RequestPage(tripUid: widget.tripUid),
  //         ),
  //       );
  //     } else {
  //       fetchNearLocation(selectedPosition?.latitude ?? 0.0,
  //           selectedPosition?.longitude ?? 0.0);
  //     }
  //   });
  // }

  void _openMapSelectionPage() async {
    selectedPosition = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(tripUid: widget.tripUid),
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
      search
          ? searchRadius
          : searchRadius2, // Search radius in meters (adjust as needed)
      type: placeType,
      keyword: placeType,
      // ตัวอย่างค้นหาร้านอาหาร
    );
    print(placeType);
    // Clear existing places
    places.clear();

    // Iterate through the results and add them to the list
    if (response.results != null) {
      for (PlacesSearchResult result in response.results!) {
        PlacesDetailsResponse detailsResponse =
            await _places.getDetailsByPlaceId(result.placeId!);
        LatLng position = LatLng(
          detailsResponse.result?.geometry?.location.lat ?? 0.0,
          detailsResponse.result?.geometry?.location.lng ?? 0.0,
        );
        String? placeProvince = await getProvinceFromCoordinates(position);
        String? placeAddress = detailsResponse.result?.formattedAddress;
        String? province = await fetchProvinceFromAddress(placeAddress ?? '');
        double latitude = detailsResponse.result?.geometry?.location.lat ?? 0.0;
        double longitude =
            detailsResponse.result?.geometry?.location.lng ?? 0.0;

        places.add(Place(
            name: result.name ?? 'Unknown',
            province: province ?? 'Unknown', // ตัวอย่างการกำหนดชื่อจังหวัด
            imageUrl: result.photos != null && result.photos!.isNotEmpty
                ? _places.buildPhotoUrl(
                    photoReference: result.photos![0].photoReference!,
                    maxWidth: 400,
                  )
                : 'https://via.placeholder.com/400', // URL ของรูปภาพตัวอย่าง
            latitude:
                latitude, // เพิ่มพารามิเตอร์ latitude ให้กับอ็อบเจกต์ Place
            longitude: longitude,
            placeprovince:
                placeProvince // เพิ่มพารามิเตอร์ longitude ให้กับอ็อบเจกต์ Place
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
