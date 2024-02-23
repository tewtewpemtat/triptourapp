import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triptourapp/addfriend.dart';
import 'package:triptourapp/friendrequest.dart';
import '../privatechat.dart';

class FriendList extends StatelessWidget {
  String? myUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(myUid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Error fetching user data');
        }

        Map<String, dynamic>? userData =
            snapshot.data?.data() as Map<String, dynamic>?;

        // Extract friendList from the user document
        List<dynamic> friendList = userData?['friendList'] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ค้นหาเพื่อนของคุณ',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFriend(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 10),
                          Text('เพิ่มเพื่อน',
                              style: GoogleFonts.ibmPlexSansThai(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendRequestPage(),
                        ),
                      );
                    },
                    child: Icon(Icons.mail),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Build a list of friend items
            if (friendList.isNotEmpty)
              for (String friendUid in friendList)
                buildTripItem(context, friendUid),

            // Move the Container and its child widgets here
          ],
        );
      },
    );
  }

  Widget buildTripItem(BuildContext context, String friendUid) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreenPage(),
            ),
          );
        },
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(4.0),
                      child: ClipOval(
                        child: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(friendUid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (snapshot.hasError || !snapshot.hasData) {
                              return Icon(Icons.error);
                            }

                            Map<String, dynamic>? friendData =
                                snapshot.data?.data() as Map<String, dynamic>?;

                            String profileImageUrl = friendData?[
                                    'profileImageUrl'] ??
                                'https://example.com/default-profile-image.jpg';

                            return Image.network(
                              profileImageUrl,
                              width: 70.0,
                              height: 70.0,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    flex: 8,
                    child: Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(friendUid)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (snapshot.hasError || !snapshot.hasData) {
                                return Text('Error fetching friend data');
                              }

                              Map<String, dynamic>? friendData = snapshot.data
                                  ?.data() as Map<String, dynamic>?;

                              String friendFirstName =
                                  friendData?['firstName'] ?? 'Unknown';
                              String friendLastName =
                                  friendData?['lastName'] ?? 'Unknown';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$friendFirstName $friendLastName',
                                    style: GoogleFonts.ibmPlexSansThai(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: FriendList(),
  ));
}
