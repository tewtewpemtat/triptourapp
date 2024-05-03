import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/invite.dart';
import 'package:triptourapp/main.dart';
import 'package:triptourapp/tripmanage/userbutton.dart';
import 'package:triptourapp/tripmanage/userplan.dart';
import 'tripmanage/headbutton.dart';
import 'tripmanage/headplan.dart';
import 'tripmanage/headinformation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:geolocator/geolocator.dart';

class TripmanagePage extends StatelessWidget {
  final String? tripUid;
  const TripmanagePage({Key? key, this.tripUid})
      : super(key: key); // Constructor ที่รับค่า UID

  Future<bool> _checkGroupChatExist(String tripUid) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('groupmessages')
        .where('tripChatUid', isEqualTo: tripUid)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<bool> _checkTripCreate(String tripUid, String myUid) async {
    DocumentSnapshot tripSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

    if (tripSnapshot.exists) {
      String? tripCreate =
          (tripSnapshot.data() as Map<String, dynamic>?)?['tripCreate'];
      return tripCreate == myUid;
    }
    return false;
  }

  Future<void> _createGroupChat(String tripUid) async {
    await FirebaseFirestore.instance.collection('groupmessages').add({
      'tripChatUid': tripUid,
      'timestampserver': FieldValue.serverTimestamp(),

      // Add other necessary fields
    });
  }

  Future<bool> _checkTripUidExist(String tripUid) async {
    DocumentSnapshot tripSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

    if (tripSnapshot.exists) {
      // เช็คว่าเอกสาร trip นั้นมีอยู่หรือไม่
      String? tripCreate =
          (tripSnapshot.data() as Map<String, dynamic>?)?['tripCreate'];
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (tripCreate == uid) {
        // ถ้าเท่ากัน ให้สร้างหน้า HeadButton
        return true;
      }
    }
    // ถ้าไม่เท่ากัน หรือไม่มีข้อมูล ให้สร้างหน้า UserButton
    return false;
  }

  Future<void> _initializeGroupChat() async {
    bool isGroupChatExist = await _checkGroupChatExist(tripUid!);
    if (!isGroupChatExist) {
      await _createGroupChat(tripUid!);
    }
  }

  Future<void> _checkLocationPermission(
      BuildContext context, String myUid) async {
    // Check if permission is already granted
    PermissionStatus status = await Permission.location.request();

    // Check if permission is granted
    if (status.isGranted) {
      // Permission is granted, proceed with fetching location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      // Store user location in database
// Store user location in database
      final userLocationRef =
          FirebaseFirestore.instance.collection('userlocation').doc(myUid);

// Check if the document already exists
      final existingDoc = await userLocationRef.get();

      if (existingDoc.exists) {
        // If document exists, update the fields
        await userLocationRef.update({
          'userLatitude': userLatitude,
          'userLongitude': userLongitude,
        });
      } else {
        // If document doesn't exist, create a new one
        await userLocationRef.set({
          'userId': myUid,
          'userLatitude': userLatitude,
          'userLongitude': userLongitude,
        });
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

  @override
  Widget build(BuildContext context) {
    String? myUid = FirebaseAuth.instance.currentUser?.uid;
    _checkLocationPermission(context, myUid ?? '');
    _initializeGroupChat();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'แผนการเดินทาง',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            FutureBuilder<bool>(
              future: _checkTripCreate(tripUid!, myUid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  bool isTripCreator = snapshot.data ?? false;
                  if (isTripCreator) {
                    return IconButton(
                      icon: Icon(Icons.person_add),
                      color: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Invite(tripUid: tripUid),
                          ),
                        );
                      },
                    );
                  } else {
                    return Text(
                        '      '); // ไม่แสดงอะไรเลยถ้าไม่ใช่ผู้สร้างทริป
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InformationPage(tripUid: tripUid),
            FutureBuilder<bool>(
              future: _checkTripUidExist(
                  tripUid!), // เรียกใช้ฟังก์ชันตรวจสอบ tripUid
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  bool isTripCreator = snapshot.data ?? false;
                  if (isTripCreator) {
                    return HeadButton(tripUid: tripUid);
                  } else {
                    return Userbutton(tripUid: tripUid);
                  }
                }
              },
            ),
            FutureBuilder<bool>(
              future: _checkTripCreate(
                  tripUid!, myUid!), // เรียกใช้ฟังก์ชันตรวจสอบ tripUid
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  bool tripUidExists = snapshot.data ?? false;
                  if (tripUidExists) {
                    return HeadPlan(tripUid: tripUid);
                  } else {
                    return UserPlan(tripUid: tripUid);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TripmanagePage(),
  ));
}
