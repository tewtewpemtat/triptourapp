import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math' show sin, cos, sqrt, pow, atan2, pi;

class DistancePage extends StatefulWidget {
  @override
  final String? tripUid;
  final String? placeid;
  const DistancePage({Key? key, this.tripUid, this.placeid}) : super(key: key);

  DistancePageState createState() => DistancePageState();
}

class DistancePageState extends State<DistancePage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String? saveTimelineOption;
  double? distance;
  double? distance2;
  @override
  void initState() {
    super.initState();
    checkDocumentExistence();
  }

  double calculateDistance(double distance) {
    double distanceInMeters = distance / 1000;
    return distanceInMeters;
  }

  void addToTimeline() {
    FirebaseFirestore.instance
        .collection('timeline')
        .where('placeid', isEqualTo: widget.placeid)
        .where('placetripid', isEqualTo: widget.tripUid)
        .where('useruid', isEqualTo: uid)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // ถ้ามีเอกสารในระบบแล้ว ให้ทำการอัปเดตเฉพาะฟิลด์ distance
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'distance': distance2}).then((value) {
            print("Document updated successfully");
          }).catchError((error) {
            print("Failed to update document: $error");
          });
        });
      } else {
        // ถ้าไม่มีเอกสารในระบบ ให้ทำการสร้างเอกสารใหม่
        FirebaseFirestore.instance.collection('timeline').add({
          'placeid': widget.placeid,
          'placetripid': widget.tripUid,
          'useruid': uid,
          'distance': distance2,
        }).then((value) {
          print("Document added successfully");
        }).catchError((error) {
          print("Failed to add document: $error");
        });
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  void checkDocumentExistence() {
    FirebaseFirestore.instance
        .collection('timeline')
        .where('placeid', isEqualTo: widget.placeid)
        .where('placetripid', isEqualTo: widget.tripUid)
        .where('useruid', isEqualTo: uid)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // ถ้ามีเอกสารใน Firestore
        setState(() {
          saveTimelineOption = 'บันทึก';
          distance2 = querySnapshot.docs.first.get('distance');
          distance = calculateDistance(distance2 ?? 0.0);
        });
      } else {
        setState(() {
          saveTimelineOption = 'ไม่บันทึก';
          distance = 0;
          distance2 = 0;
        });
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  double calculateDistanceInMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the earth in meters

    // Convert degrees to radians
    double lat1Rad = radians(lat1);
    double lon1Rad = radians(lon1);
    double lat2Rad = radians(lat2);
    double lon2Rad = radians(lon2);

    // Haversine formula
    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double radians(double degrees) {
    return degrees * (pi / 180);
  }

  void deleteFromTimeline() {
    FirebaseFirestore.instance
        .collection('timeline')
        .where('placeid', isEqualTo: widget.placeid)
        .where('placetripid', isEqualTo: widget.tripUid)
        .where('useruid', isEqualTo: uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete().then((value) {
          print("Document deleted successfully");
        }).catchError((error) {
          print("Failed to delete document: $error");
        });
      });
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  void changeDistace() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ระยะในการบันทึก (เมตร)'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'ระยะในการบันทึก (เมตร)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            double doubleValue = double.tryParse(value) ?? 0.0;
            print(doubleValue);
            distance2 = doubleValue;
            // แปลงเป็นข้อความ
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // เมื่อผู้ใช้ป้อนระยะห่างในการค้นหาแล้วให้ดึงสถานที่ใกล้เคียงตามระยะที่ระบุ
              if (distance2 != 0.0) {
                setState(() {
                  distance = calculateDistance(distance2 ?? 0.0);
                  // แปลงเป็นข้อความ
                });
                Fluttertoast.showToast(
                  msg: "บันทึกระยะสำเร็จ",
                  toastLength: Toast.LENGTH_LONG,
                );

                setState(() {
                  saveTimelineOption = 'บันทึก';
                });

                addToTimeline();
              } else {
                setState(() {
                  saveTimelineOption = 'ไม่บันทึก';
                });
              }
            },
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void deleteDistace() async {
    setState(() {
      distance = 0;
      distance2 = 0;
    });
    setState(() {
      saveTimelineOption = 'ไม่บันทึก';
    });
    deleteFromTimeline();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 5),
              Text(
                "ตัวเลือกการบันทึกไทมไลน์  ",
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: saveTimelineOption,
                onChanged: (String? newValue) {
                  if (newValue == 'บันทึก') {
                    changeDistace();
                  }
                  if (newValue == 'ไม่บันทึก') {
                    deleteDistace();
                  }
                },
                items: <String>['บันทึก', 'ไม่บันทึก'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              saveTimelineOption == 'บันทึก' && distance != 0.0
                  ? Text(
                      "$distance Km.",
                      style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )
                  : Text(
                      "",
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DistancePage(),
  ));
}
