import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triptourapp/notificationcheck/notificationfunction.dart';
import 'package:triptourapp/notificationsend.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Invite extends StatefulWidget {
  final String? tripUid;
  const Invite({Key? key, this.tripUid}) : super(key: key);
  InviteState createState() => InviteState();
}

class InviteState extends State<Invite> {
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
  late List<dynamic> friendList = [];

  @override
  void initState() {
    super.initState();
    fetchFriendList();
  }

  void fetchFriendList() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(myUid).get();

      if (userDataSnapshot.exists) {
        Map<String, dynamic>? userData = userDataSnapshot.data();

        if (userData != null &&
            userData['friendList'] != null &&
            (userData['friendList'] as Iterable).isNotEmpty) {
          List<String> allFriends = List<String>.from(userData['friendList']);

          DocumentSnapshot<Map<String, dynamic>> tripSnapshot =
              await FirebaseFirestore.instance
                  .collection('trips')
                  .doc(widget.tripUid)
                  .get();

          if (tripSnapshot.exists) {
            Map<String, dynamic> tripData = tripSnapshot.data() ?? {};
            List<String> tripParticipants =
                List<String>.from(tripData['tripJoin'] ?? []);

            setState(() {
              friendList = allFriends
                  .where((friendUid) => !tripParticipants.contains(friendUid))
                  .toList();
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void sendTripRequest(String friendUid) async {
    try {
      QuerySnapshot<Map<String, dynamic>> tripRequestSnapshot =
          await FirebaseFirestore.instance
              .collection('triprequest')
              .where('senderUid', isEqualTo: myUid)
              .where('receiverUid', isEqualTo: friendUid)
              .where('status', isEqualTo: 'Waiting')
              .where('tripUid', isEqualTo: widget.tripUid)
              .get();

      if (tripRequestSnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('triprequest').add({
          'tripUid': widget.tripUid,
          'senderUid': myUid,
          'receiverUid': friendUid,
          'status': 'Waiting',
          'sendStatus': 'no',
        });

        print('Friend request sent successfully');
      } else {
        print('Friend request already sent');
      }
      await InviteTripNotification(friendUid);
      Fluttertoast.showToast(msg: 'ส่งคำเชิญเเล้ว');
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เชิญเพื่อน'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TripmanagePage(tripUid: widget.tripUid)),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffeaeaea),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [],
                ),
              ),
            ),
            SizedBox(height: 10),
            if (friendList.isNotEmpty)
              for (String friendUid in friendList)
                buildTripItem(context, friendUid),
          ],
        ),
      ),
    );
  }

  Widget buildTripItem(BuildContext context, String friendUid) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(friendUid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('');
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Icon(Icons.error);
        }
        Map<String, dynamic>? friendData =
            snapshot.data?.data() as Map<String, dynamic>?;

        return Material(
          child: InkWell(
            child: Container(
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(4.0),
                      child: ClipOval(
                        child: Image.network(
                          friendData?['profileImageUrl'] ??
                              'https://example.com/default-profile-image.jpg',
                          width: 70.0,
                          height: 70.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${friendData?['firstName']} ${friendData?['lastName']}',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              sendTripRequest(friendUid);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void main() async {
  runApp(MaterialApp(
    home: Scaffold(
      body: Invite(),
    ),
  ));
}
