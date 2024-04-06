import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/infoplace/distancechoose.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' show sin, cos, sqrt, pow, atan2, pi;

class Locationfetch extends StatefulWidget {
  @override
  final String? tripUid;
  final String? placeid;
  const Locationfetch({Key? key, this.tripUid, this.placeid}) : super(key: key);

  LocationfetchState createState() => LocationfetchState();
}

class LocationfetchState extends State<Locationfetch> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  double userLatitude = 0.0; // พิกัดละติจูดปัจจุบันของผู้ใช้
  double userLongitude = 0.0; // พิกัดลองจิจูดปัจจุบันของผู้ใช้
  double placeLatitude = 0.0; // พิกัดละติจูดปัจจุบันของผู้ใช้
  double placeLongitude = 0.0; // พิกัดลองจิจูดปัจจุบันของผู้ใช้
  double? distance;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(Duration(seconds: 5), (Timer t) => getUserLocation());
    getPlaceLocation();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void getUserLocation() async {
    try {
      checkDocumentExistence();
      if (distance! > 0.0) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        double latitude = position.latitude;
        double longitude = position.longitude;

        await FirebaseFirestore.instance
            .collection('userlocation')
            .doc(uid)
            .update({
          'userLatitude': position.latitude,
          'userLongitude': position.longitude,
        });
        double distanceInMeters = calculateDistanceInMeters(
          latitude,
          longitude,
          placeLatitude,
          placeLongitude,
        );
        print(distanceInMeters);
        num distanceNum = distance!.toDouble();
        if (distanceInMeters <= distanceNum) {
          // User is entering the location
          print("ผู้ใช้เข้าสถานที่");

          // Record entry time in Firestore
          await FirebaseFirestore.instance.collection('timelinestamp').add({
            'useruid': uid,
            'placeid': widget.placeid,
            'placetripid': widget.tripUid,
            'intime': DateTime.now(),
            'outtime': null, // Assuming the user hasn't exited yet
          });
        } else {
          // User is exiting the location
          print("User exited the location");

          // Update exit time in Firestore
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('timelinestamp')
              .where('useruid', isEqualTo: uid)
              .where('placeid', isEqualTo: widget.placeid)
              .where('placetripid', isEqualTo: widget.tripUid)
              .where('outtime',
                  isEqualTo: null) // Fetch only entries without exit time
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            // Update exit time for the first matching document
            String docId = querySnapshot.docs.first.id;
            await FirebaseFirestore.instance
                .collection('timelinestamp')
                .doc(docId)
                .update({'outtime': DateTime.now()});
          }
        }
      }
    } catch (error) {
      print("Error getting user location: $error");
    }
  }

  void getPlaceLocation() async {
    try {
      DocumentSnapshot userLocationSnapshot = await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.placeid)
          .get();

      if (userLocationSnapshot.exists) {
        double latitude = userLocationSnapshot['placeLatitude'];
        double longitude = userLocationSnapshot['placeLongitude'];

        // Update userLatitude and userLongitude
        setState(() {
          placeLatitude = latitude;
          placeLongitude = longitude;
        });
      }
    } catch (error) {
      print("Error getting user location: $error");
    }
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
          distance = querySnapshot.docs.first.get('distance');
        });
      } else {
        setState(() {
          distance = 0.0;
        });
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  double radians(double degrees) {
    return degrees * (pi / 180);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Locationfetch(),
  ));
}
