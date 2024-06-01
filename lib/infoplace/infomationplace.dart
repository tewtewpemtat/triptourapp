import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triptourapp/infoplace/maproute.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show sin, cos, sqrt, pow, atan2, pi;

class InformationPlan extends StatefulWidget {
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
  double userLatitude = 0.0;
  double userLongitude = 0.0;

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
            child: Text(''),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text('ไม่พบข้อมูลสถานที่'),
          );
        }

        final placeData = snapshot.data!.data() as Map<String, dynamic>;

        return buildPlaceItem(context, placeData, snapshot.data!);
      },
    );
  }

  void rounttomap(double placeLatitude, double placeLongitude, context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          tripUid: widget.tripUid,
          placeid: widget.placeid,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          placeLatitude: placeLatitude,
          placeLongitude: placeLongitude,
        ),
      ),
    );
  }

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          userLatitude = position.latitude;
          userLongitude = position.longitude;
        });
      }
    } catch (e) {
      print("Error getting user location: $e");
    }
  }

  double calculateDistance(double userLatitude, double userLongitude,
      double placeLatitude, double placeLongitude) {
    const double earthRadius = 6371.0;
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

  double radians(double degrees) {
    return degrees * (pi / 180);
  }

  Widget buildPlaceItem(
      BuildContext context, Map<String, dynamic> placeData, place) {
    String placeName = placeData['placename'];
    int maxCharsFirstLine = 40;
    int maxCharsTotal = 40;

    int countTrip = placeData['placewhogo'].length;

    double distance = calculateDistance(userLatitude, userLongitude,
        placeData['placeLatitude'], placeData['placeLongitude']);
    String distanceText = distance.toStringAsFixed(2) + ' กิโลเมตร';
    String displayedName = placeName.length > maxCharsFirstLine
        ? (placeName.length > maxCharsTotal
            ? placeName.substring(0, maxCharsFirstLine) + '...'
            : placeName.substring(0, maxCharsFirstLine) +
                '...' +
                (placeName.length > maxCharsTotal
                    ? placeName.substring(maxCharsFirstLine, maxCharsTotal) +
                        '...'
                    : placeName.substring(maxCharsFirstLine)))
        : placeName;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {},
        child: Container(
          height: 200.0,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
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
              SizedBox(width: 3),
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
                                displayedName,
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
                              color: Colors.black,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                            color: Color(0xFF1E30D7),
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
                                    (placeData['placetimestart'] as Timestamp)
                                        .toDate()),
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
                                        .toDate()),
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
