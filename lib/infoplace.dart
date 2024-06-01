import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/infoplace/distancechoose.dart';
import 'package:triptourapp/infoplace/locationfetch.dart';
import 'package:triptourapp/notificationcheck.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'infoplace/groupchat.dart';
import 'infoplace/headinfobutton.dart';
import 'infoplace/infomationplace.dart';
import 'infoplace/member.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class InfoPlacePage extends StatefulWidget {
  final String? tripUid;
  final String? placeid;
  const InfoPlacePage({Key? key, this.tripUid, this.placeid}) : super(key: key);

  InfoPlacePageState createState() => InfoPlacePageState();
}

class InfoPlacePageState extends State<InfoPlacePage> {
  double userLatitude = 0.0;
  double userLongitude = 0.0;
  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userLocationSnapshot = await FirebaseFirestore.instance
          .collection('userlocation')
          .doc(uid)
          .get();

      if (userLocationSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection('userlocation')
            .doc(uid)
            .update({
          'userLatitude': position.latitude,
          'userLongitude': position.longitude,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('userlocation')
            .doc(uid)
            .set({
          'userId': uid,
          'userLatitude': position.latitude,
          'userLongitude': position.longitude,
        });
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TripmanagePage(tripUid: widget.tripUid),
              ),
            );
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'แผนการเดินทาง',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansThai(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            IconButton(
              color: Colors.black,
              icon: Icon(Icons.chat),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupScreenPage(
                              tripUid: widget.tripUid ?? '',
                              placeid: widget.placeid ?? '',
                            )));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InformationPlan(tripUid: widget.tripUid, placeid: widget.placeid),
            DistancePage(tripUid: widget.tripUid, placeid: widget.placeid),
            HeadInfoButton(tripUid: widget.tripUid, placeid: widget.placeid),
            MemberPage(tripUid: widget.tripUid, placeid: widget.placeid),
            Locationfetch(tripUid: widget.tripUid, placeid: widget.placeid),
            NotificationCheck(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InfoPlacePage(),
  ));
}
