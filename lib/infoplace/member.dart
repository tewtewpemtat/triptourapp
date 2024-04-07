import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:triptourapp/infoplace/headinfobutton.dart';
import 'package:triptourapp/infoplace/userlocation.dart';

class MemberPage extends StatefulWidget {
  @override
  final String? tripUid;
  final String? placeid;
  const MemberPage({Key? key, this.tripUid, this.placeid}) : super(key: key);

  MemberPageState createState() => MemberPageState();
}

class MemberPageState extends State<MemberPage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  double userLatitude = 0.0; // พิกัดละติจูดปัจจุบันของผู้ใช้
  double userLongitude = 0.0; // พิกัดลองจิจูดปัจจุบันของผู้ใช้

  @override
  void initState() {
    super.initState();
    getUserLocation();
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .doc(widget.placeid)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text(''));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text('ไม่พบข้อมูลสถานที่'),
          );
        }
        // Retrieve the data from the document snapshot
        final placeData = snapshot.data!.data() as Map<String, dynamic>;

        // Continue with your UI logic using placeData
        return buildTripItem(context, placeData, snapshot.data!);
      },
    );
  }

  Widget buildTripItem(
      BuildContext context, Map<String, dynamic> placeData, place) {
    List<dynamic> usersList = placeData['placewhogo'];

    return Material(
      child: Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          children: [
            for (var userData in usersList)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userData)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text(''));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(
                      child: Text('ไม่พบข้อมูลผู้ใช้'),
                    );
                  }

                  Map<String, dynamic> userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return buildUserItem(userData, snapshot.data!.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> getUsersData(List<dynamic> usersList) {
    return FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: usersList)
        .snapshots();
  }

  Widget buildUserItem(Map<String, dynamic> userData, String docid) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, // สีของเส้นกรอบ
          width: 1.0, // ความหนาของเส้นกรอบ
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.all(4.0),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(userData['profileImageUrl'] ?? ''),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Text(
              userData['nickname'] ?? '',
              style: GoogleFonts.ibmPlexSansThai(
                fontSize: 18,
                color: const Color.fromARGB(255, 11, 11, 11),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          uid != docid
              ? IconButton(
                  icon: Icon(Icons.location_on_outlined),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserLocationShow(
                            userLatitude: userLatitude,
                            userLongitude: userLongitude,
                            friendId: docid,
                            tripUid: widget.tripUid,
                            placeid: widget.placeid),
                      ),
                    );
                  },
                  tooltip: 'ดูตำแหน่ง',
                )
              : Text(""),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MemberPage(),
  ));
}
