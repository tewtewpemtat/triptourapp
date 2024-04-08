import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math' show sin, cos, sqrt, pow, atan2, pi;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:triptourapp/infoplace/interestmap.dart';
import 'package:triptourapp/infoplace/interestmapthing.dart';
import 'package:triptourapp/infoplace/userlocationmap.dart';
import 'dart:async';
import '../infoplace.dart';
import 'package:intl/intl.dart';
import 'dart:math' show radians;

class UserLocation {
  final String uid;
  final double latitude;
  final double longitude;

  UserLocation({
    required this.uid,
    required this.latitude,
    required this.longitude,
  });
}

class HeadInfoButton extends StatefulWidget {
  @override
  final String? tripUid;
  final String? placeid;
  const HeadInfoButton({Key? key, this.tripUid, this.placeid})
      : super(key: key);

  HeadInfoButtonState createState() => HeadInfoButtonState();
}

class HeadInfoButtonState extends State<HeadInfoButton> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool showMapBlock = false;
  bool showMapThing = false;
  bool thing = false;
  List<UserLocation>? userLocations;
  List<String>? users;
  @override
  void initState() {
    super.initState();
    showMapBlock = false;
    showMapThing = false;
    _showUserLocationsOnMap();
  }

  void _showUserLocationsOnMap() async {
    // Call getUserLocations to fetch user locations
    List<UserLocation> userLocations = await getUserLocations();

    // If there are user locations, display them on the map
    if (userLocations.isNotEmpty) {
      print("yes");
    } else {
      print("no");
    }
  }

  Future<List<UserLocation>> getUserLocations() async {
    List<UserLocation> userLocations = [];

    try {
      // Fetch the placewhogo field from the places collection for the specified placeid
      DocumentSnapshot placeSnapshot = await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.placeid)
          .get();
      List<String> userUids = List<String>.from(placeSnapshot['placewhogo']);
      setState(() {
        users = userUids;
      });
      for (String userUid in userUids) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('userlocation')
            .doc(userUid)
            .get();
        if (userSnapshot.exists) {
          // Extract latitude and longitude from the user's location document
          double latitude = userSnapshot['userLatitude'];
          double longitude = userSnapshot['userLongitude'];

          // Create a UserLocation object and add it to the list
          userLocations.add(UserLocation(
              uid: userUid, latitude: latitude, longitude: longitude));
        }
      }
    } catch (error) {
      print("Error getting user locations: $error");
    }

    return userLocations;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showMapBlock = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // สีพื้นหลังของปุ่ม
                    onPrimary: Colors.black, // สีขอบตัวอักษร
                    fixedSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.place),
                      SizedBox(width: 8),
                      Text('ตำแหน่งผู้ร่วมทริป',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: showMapBlock,
                child: Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 300,
                        color: Colors.grey,
                        child: Center(
                            child: UserLocationMap(
                                userLocations: users ?? [],
                                placeid: widget.placeid ?? '')),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showMapBlock = false;
                            });
                          },
                          child: Icon(
                            Icons.remove, // แทนด้วย icon ที่คุณต้องการ
                            color: Colors.red, // สีของ icon
                            size: 30, // ขนาดของ icon
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      thing = true;
                      showMapThing = false;
                      showMapThing = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // สีพื้นหลังของปุ่ม
                    onPrimary: Colors.black, // สีขอบตัวอักษร
                    fixedSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map),
                      SizedBox(width: 5),
                      Text('จุดนัดพบบนแผนที่',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      thing = false;
                      showMapThing = false;
                      showMapThing = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // สีพื้นหลังของปุ่ม
                    onPrimary: Colors.black, // สีขอบตัวอักษร
                    fixedSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star),
                      SizedBox(width: 8),
                      Text('สิ่งน่าสนใจ',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          thing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: showMapThing,
                      child: Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 300,
                              color: Colors.grey,
                              child: Center(
                                  child: InterestMap(
                                      tripUid: widget.tripUid,
                                      placeid: widget.placeid)),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showMapThing = false;
                                  });
                                },
                                child: Icon(
                                  Icons.remove, // แทนด้วย icon ที่คุณต้องการ
                                  color: Colors.red, // สีของ icon
                                  size: 30, // ขนาดของ icon
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: showMapThing,
                      child: Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 300,
                              color: Colors.grey,
                              child: Center(
                                  child: InterestMap2(
                                tripUid: widget.tripUid,
                                placeid: widget.placeid,
                              )),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showMapThing = false;
                                  });
                                },
                                child: Icon(
                                  Icons.remove, // แทนด้วย icon ที่คุณต้องการ
                                  color: Colors.red, // สีของ icon
                                  size: 30, // ขนาดของ icon
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: HeadInfoButton(),
    ),
  );
}
