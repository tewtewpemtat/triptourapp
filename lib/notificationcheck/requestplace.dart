import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triptourapp/service/notification.dart';

class placeCheck extends StatefulWidget {
  final String? tripUid;
  placeCheck({required this.tripUid});

  @override
  _placeCheckState createState() => _placeCheckState();
}

class _placeCheckState extends State<placeCheck> {
  String? tripCreate;

  @override
  void initState() {
    super.initState();
    getTripCreate(widget.tripUid);
  }

  void getTripCreate(String? tripUid) async {
    DocumentSnapshot tripDoc =
        await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();
    if (tripDoc.exists) {
      setState(() {
        tripCreate = tripDoc['tripCreate'];
      });
    } else {
      setState(() {
        tripCreate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .where('placetripid', isEqualTo: widget.tripUid)
          .where('placenotification', isEqualTo: 'no')
          .where('useruid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Container();
        } else {
          int numberPlace = snapshot.data!.docs.length;
          int numberPlaceList = 0;
          for (DocumentSnapshot doc in snapshot.data!.docs) {
            doc.reference.update({'placenotification': 'yes'});
            numberPlaceList++;
          }
          if (numberPlace > 0) {
            NotificationService().showNotification(
              title: 'แจ้งเตือน',
              body: 'ทริปของคุณมีการแนะนำสถานที่ใหม่ $numberPlaceList รายการ}',
            );
          }
          return Container();
        }
      },
    );
  }
}
