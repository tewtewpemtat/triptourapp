import 'package:flutter/material.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' show sin, cos, sqrt, atan2, pi;

class Locationfetch extends StatefulWidget {
  final String? tripUid;
  final String? placeid;
  const Locationfetch({Key? key, this.tripUid, this.placeid}) : super(key: key);

  LocationfetchState createState() => LocationfetchState();
}

class LocationfetchState extends State<Locationfetch> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  double userLatitude = 0.0;
  double userLongitude = 0.0;
  double placeLatitude = 0.0;
  double placeLongitude = 0.0;
  DateTime? placeEndTime;
  double? distance;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    if (mounted) {
      timer =
          Timer.periodic(Duration(seconds: 5), (Timer t) => getUserLocation());
    }
    getPlaceLocation();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void stopTimer() {
    timer.cancel();
  }

  void getUserLocation() async {
    try {
      checkPlaceStatus();
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
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('timelinestamp')
              .where('useruid', isEqualTo: uid)
              .where('placeid', isEqualTo: widget.placeid)
              .where('placetripid', isEqualTo: widget.tripUid)
              .where('outtime', isEqualTo: "Wait")
              .get();

          if (querySnapshot.docs.isEmpty) {
            await FirebaseFirestore.instance.collection('timelinestamp').add({
              'useruid': uid,
              'placeid': widget.placeid,
              'placetripid': widget.tripUid,
              'distance': distanceNum,
              'intime': DateTime.now(),
              'outtime': "Wait",
            });
          }
          print("ผู้ใช้อยู่ในสถานที่");
        } else {
          print("ผู้ใช้อยู่นอกสถานที่");

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('timelinestamp')
              .where('useruid', isEqualTo: uid)
              .where('placeid', isEqualTo: widget.placeid)
              .where('placetripid', isEqualTo: widget.tripUid)
              .where('outtime', isEqualTo: "Wait")
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            String docId = querySnapshot.docs.first.id;
            await FirebaseFirestore.instance
                .collection('timelinestamp')
                .doc(docId)
                .update({'outtime': DateTime.now()});
          } else {
            Text("ไม่บันทึกไทมไลน");
          }
        }
      } else {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        await FirebaseFirestore.instance
            .collection('userlocation')
            .doc(uid)
            .update({
          'userLatitude': position.latitude,
          'userLongitude': position.longitude,
        });
      }
    } catch (error) {
      print("กำลังดำเนินการบันทึกตำแหน่ง");
    }
  }

  void checkPlaceStatus() async {
    try {
      DateTime currentTime = DateTime.now();

      if (currentTime.isAfter(placeEndTime ?? DateTime.now())) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TripmanagePage(tripUid: widget.tripUid),
          ),
        );
      }
    } catch (error) {
      print("Error getting place status: $error");
    }
  }

  void getPlaceLocation() async {
    try {
      DocumentSnapshot userLocationSnapshot = await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.placeid)
          .get();

      if (userLocationSnapshot.exists) {
        DateTime placeEndTimeCheck =
            userLocationSnapshot['placetimeend'].toDate();
        double latitude = userLocationSnapshot['placeLatitude'];
        double longitude = userLocationSnapshot['placeLongitude'];

        setState(() {
          placeLatitude = latitude;
          placeLongitude = longitude;
          placeEndTime = placeEndTimeCheck;
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
    const double earthRadius = 6371000;

    double lat1Rad = radians(lat1);
    double lon1Rad = radians(lon1);
    double lat2Rad = radians(lat2);
    double lon2Rad = radians(lon2);

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
