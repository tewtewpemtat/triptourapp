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
import 'mapselect.dart';
import 'package:triptourapp/addplace/mapselectown.dart';

import '../infoplace.dart';

class HeadPlan extends StatefulWidget {
  @override
  final String? tripUid;
  const HeadPlan({Key? key, this.tripUid}) : super(key: key);
  _HeadPlanPageState createState() => _HeadPlanPageState();
}

class _HeadPlanPageState extends State<HeadPlan> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isPlaceLength = false;
  bool isPlaceEnd = false;
  bool isPlaceStart = false;
  double? placelat;
  double? placelong;
  LatLng? selectedPosition = null;
  LatLng? markedPosition;
  @override
  Widget build(BuildContext context) {
    return // Set a fixed height or use constraints
        StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .where('placetripid', isEqualTo: widget.tripUid)
          .where('placeadd', isEqualTo: "Yes")
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Center(
              child: Text('ยังไม่มีการกำหนดสถานที่'),
            );
          });
        }
        final places = snapshot.data!.docs;
        if (places != null) {
          places.sort((a, b) {
            final aEndTime = a['placetimeend'] as Timestamp;
            final bEndTime = b['placetimeend'] as Timestamp;
            return aEndTime.compareTo(bEndTime);
          });

          return Column(
            children: places.map((place) {
              final placeData = place.data() as Map<String, dynamic>;
              return buildPlaceItem(context, placeData, place);
            }).toList(),
          );
        } else {
          return Container();
        }
      },
    );
  }

  void _openMapSelectionPage(DocumentSnapshot place, double placelat,
      double placelong, context) async {
    print(placelat);
    selectedPosition = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(
            tripUid: widget.tripUid, placelat: placelat, placelong: placelong),
      ),
    );
    if (selectedPosition != null) {
      FirebaseFirestore.instance.collection('places').doc(place.id).update({
        'placestart':
            GeoPoint(selectedPosition!.latitude, selectedPosition!.longitude)
      }).then((value) {
        // Update successful
      }).catchError((error) {
        // Error handling
        print("Failed to update placestart: $error");
        Fluttertoast.showToast(
            msg: "Failed to update placestart: $error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
  }

  Widget buildPlaceItem(
      BuildContext context, Map<String, dynamic> placeData, place) {
    String placeName = placeData['placename'];
    String placeAddress = placeData['placeaddress'];
    int maxCharsFirstLine = 40; // Maximum characters for the first line
    int maxCharsTotal = 40; // Maximum characters to display in total
    int maxCharsFirstLine2 = 50; // Maximum characters for the first line
    int maxCharsTotal2 = 60; // Maximum characters to display in total
    Timestamp placeStartTimeStamp = placeData[
        'placetimestart']; // เพิ่มการเข้าถึง placetimestart จาก placeData
    Timestamp placeEndTimeStamp = placeData['placetimeend'];
    DateTime placeStartTime =
        placeStartTimeStamp.toDate(); // แปลง Timestamp เป็น DateTime
    DateTime placeEndTime = placeEndTimeStamp.toDate();
    bool placestart;
    int countTrip = placeData['placewhogo'].length;
    if (placeData['placestart'] == '') {
      placestart = true;
    } else {
      placestart = false;
    }
    // เงื่อนไขเพิ่มเติมเพื่อตรวจสอบว่า placetimestart มีค่ามากกว่าหรือเท่ากับวันเวลาปัจจุบันหรือไม่
    bool isPlaceTimeValid = placeStartTime.isAfter(DateTime.now()) ||
        placeStartTime.isAtSameMomentAs(DateTime.now());

    isPlaceEnd = DateTime.now().isAfter(placeStartTime) &&
        DateTime.now().isAfter(placeEndTime);
    isPlaceStart = DateTime.now().isBefore(placeStartTime);
    isPlaceLength = DateTime.now().isAfter(placeStartTime) &&
        DateTime.now().isBefore(placeEndTime);
    if (isPlaceLength) {
      place.reference.update({'placerun': 'Running'});
    }
    if (isPlaceEnd) {
      place.reference.update({'placerun': 'End'});
    }

    // Update the placerun field in Firestore based on the time condition

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
      child: Container(
        height: 200.0,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey, // Border color
              width: 1.0, // Border width
            ),
            borderRadius: BorderRadius.circular(10),
            color: !isPlaceLength & !isPlaceStart
                ? Color.fromARGB(53, 106, 105, 105)
                : Color.fromARGB(255, 255, 255, 255)),
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
                                      (placeData['placetimestart'] as Timestamp)
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
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: isPlaceTimeValid
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          _openMapSelectionPage(
                                              place,
                                              placeData['placeLatitude'] ??
                                                  13.736717,
                                              placeData['placeLongitude'] ??
                                                  100.523186,
                                              context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Color.fromARGB(
                                              255, 167, 166, 166),
                                          onPrimary: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fixedSize: Size(70, 10),
                                        ),
                                        child: placestart
                                            ? Text(
                                                'กำหนดจุดนัดพบ',
                                                style:
                                                    GoogleFonts.ibmPlexSansThai(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                              )
                                            : Text(
                                                'จุดนัดพบ',
                                                style:
                                                    GoogleFonts.ibmPlexSansThai(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                              )),
                                  )
                                : Container(
                                    width: 70,
                                    height: 40,
                                    child: TextButton(
                                      onPressed: null,
                                      child: Text(
                                        'จุดนัดพบ',
                                        style: GoogleFonts.ibmPlexSansThai(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 49, 49, 49),
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey,
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HeadPlan(),
  ));
}
