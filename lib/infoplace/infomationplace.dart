import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triptourapp/tripmanage/maproute.dart';
import 'package:triptourapp/addplace/mapselectown.dart';
import 'package:geolocator/geolocator.dart';
import '../infoplace.dart';
import 'dart:math' show sin, cos, sqrt, pow, atan2, pi;

class InformationPlan extends StatefulWidget {
  @override
  final String? tripUid;
  final String? placeid;
  const InformationPlan({Key? key, this.tripUid, this.placeid})
      : super(key: key);

  InformationPlanState createState() => InformationPlanState();
}

class InformationPlanState extends State<InformationPlan> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isPlaceLength = false;
  bool isPlaceEnd = false;
  bool isPlaceStart = false;
  double? placelat;
  double? placelong;
  LatLng? selectedPosition = null;
  LatLng? markedPosition;
  double userLatitude = 0.0; // พิกัดละติจูดปัจจุบันของผู้ใช้
  double userLongitude = 0.0; // พิกัดลองจิจูดปัจจุบันของผู้ใช้

  @override
  void initState() {
    super.initState();

    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .doc(widget.placeid)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text('ไม่พบข้อมูลสถานที่'),
          );
        }

        // Retrieve the data from the document snapshot
        final placeData = snapshot.data!.data() as Map<String, dynamic>;

        // Continue with your UI logic using placeData
        return buildPlaceItem(context, placeData, snapshot.data!);
      },
    );
  }

  void rounttomap(double placeLatitude, double placeLongitude, context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          placeLatitude: placeLatitude, // ประกาศพารามิเตอร์ placelatitude
          placeLongitude: placeLongitude, // ประกาศพารามิเตอร์ placelongitude
        ),
      ),
    );
  }

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    } catch (e) {
      print("Error getting user location: $e");
    }
  }

  double calculateDistance(double userLatitude, double userLongitude,
      double placeLatitude, double placeLongitude) {
    const double earthRadius = 6371.0; // รัศมีของโลกในหน่วยกิโลเมตร
    double lat1Rad = radians(userLatitude);
    double lon1Rad = radians(userLongitude);
    double lat2Rad = radians(placeLatitude);
    double lon2Rad = radians(placeLongitude);

    double deltaLon = lon2Rad - lon1Rad;
    double deltaLat = lat2Rad - lat1Rad;

    double a = pow(sin(deltaLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  // เปลี่ยนจากองศาเป็นเรเดียน
  double radians(double degrees) {
    return degrees * (pi / 180);
  }

  Widget buildPlaceItem(
      BuildContext context, Map<String, dynamic> placeData, place) {
    String placeName = placeData['placename'];
    String placeAddress = placeData['placeaddress'];
    int maxCharsFirstLine = 40; // Maximum characters for the first line
    int maxCharsTotal = 40; // Maximum characters to display in total
    int maxCharsFirstLine2 = 50; // Maximum characters for the first line
    int maxCharsTotal2 = 60; // Maximum characters to display in total
    int countTrip = placeData['placewhogo'].length;

    // Update the placerun field in Firestore based on the time condition
    double distance = calculateDistance(userLatitude, userLongitude,
        placeData['placeLatitude'], placeData['placeLongitude']);
    String distanceText =
        distance.toStringAsFixed(2) + ' กิโลเมตร'; // แปลงเป็นข้อความ
    String displayedName = placeName.length > maxCharsFirstLine
        ? (placeName.length > maxCharsTotal
            ? placeName.substring(0, maxCharsFirstLine) +
                '...' // Add ... after truncating the first line
            : placeName.substring(0, maxCharsFirstLine) +
                '...' +
                (placeName.length > maxCharsTotal
                    ? placeName.substring(maxCharsFirstLine, maxCharsTotal) +
                        '...'
                    : placeName.substring(maxCharsFirstLine)))
        : placeName;
    String displayedName2 = placeAddress.length > maxCharsFirstLine2
        ? (placeAddress.length > maxCharsTotal2
            ? placeAddress.substring(0, maxCharsFirstLine2) +
                '...' // Add ... after truncating the first line
            : placeAddress.substring(0, maxCharsFirstLine2) +
                '\n' +
                (placeAddress.length > maxCharsTotal2
                    ? placeAddress.substring(
                            maxCharsFirstLine2, maxCharsTotal2) +
                        '...'
                    : placeAddress.substring(maxCharsFirstLine2)))
        : placeAddress;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {},
        child: Container(
          height: 200.0,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // Border color
                width: 1.0, // Border width
              ),
              borderRadius: BorderRadius.circular(10),
              color: Color.fromARGB(255, 255, 255, 255)),
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    placeData['placepicUrl'] ??
                        'assets/userplan/userplan_image1.png',
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 13),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayedName ?? '',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                            color: Color(0xFF1E30D7), // Background color
                          ),
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            placeData['placeprovince'] ?? '',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Color(0xffdb923c),
                              ),
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                'วันเวลาเริ่มต้น',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                DateFormat('dd-MM-yyy HH:mm').format(
                                        (placeData['placetimestart']
                                                as Timestamp)
                                            .toDate()) ??
                                    '',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Color(0xffc21111),
                              ),
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                'วันเวลาสิ้นสุด',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                DateFormat('dd-MM-yyy HH:mm').format(
                                        (placeData['placetimeend'] as Timestamp)
                                            .toDate()) ??
                                    '',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          'จำนวนผู้เข้าร่วม : $countTrip',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'หากจากคุณ : $distanceText',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: 70,
                                height: 40,
                                child: TextButton(
                                  onPressed: () {
                                    if (placeData['placestart'] != '') {
                                      rounttomap(placeData['placeLatitude'],
                                          placeData['placeLongitude'], context);
                                    }
                                  },
                                  child: Text(
                                    'นำทางไปสถานที่',
                                    style: GoogleFonts.ibmPlexSansThai(
                                      fontWeight: FontWeight.w700,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 245, 156, 68),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InformationPlan(),
  ));
}
