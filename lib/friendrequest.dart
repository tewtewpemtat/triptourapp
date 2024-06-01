import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/friend.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: FriendRequestPage(),
  ));
}

class FriendRequestPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "ตอบรับคำเชิญเพื่อน",
          style: GoogleFonts.ibmPlexSansThai(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Friend()),
            );
          },
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('friendrequest')
            .where('receiverUid',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('status', isEqualTo: 'Wait')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data!.docs.isEmpty) {
            return Container(
                margin: EdgeInsets.all(10), child: Text('ไม่พบคำขอ'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var friendRequestData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String senderUid = friendRequestData['senderUid'];

                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(senderUid)
                      .get(),
                  builder:
                      (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Text('');
                    } else if (userSnapshot.hasError) {
                      return Text('Error: ${userSnapshot.error}');
                    } else if (!userSnapshot.hasData) {
                      return Center(
                        child: Text('ไม่พบข้อมูลผู้ใช้'),
                      );
                    } else {
                      var userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;

                      String firstName = userData['firstName'] ?? '';
                      String lastName = userData['lastName'] ?? '';
                      String nickName = userData['nickname'] ?? '';

                      String profileImageUrl =
                          userData['profileImageUrl'] ?? '';

                      return InkWell(
                        onTap: () {
                          print('Tapped on friend request item');
                        },
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          padding: EdgeInsets.all(0.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            border: Border.all(
                              color: Color.fromARGB(255, 222, 216, 216),
                              width: 2.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: 120.0,
                                  height: 120.0,
                                  child: ClipOval(
                                    child: profileImageUrl.isNotEmpty
                                        ? Image.network(
                                            profileImageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/jointrip/mail_image1.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('$firstName $lastName',
                                          style: GoogleFonts.ibmPlexSansThai(
                                            fontSize: 16,
                                          )),
                                      Text('$nickName',
                                          style: GoogleFonts.ibmPlexSansThai(
                                            fontSize: 12,
                                          )),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            height: 30,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  String senderUid =
                                                      friendRequestData[
                                                          'senderUid'];
                                                  String? receiverUid =
                                                      FirebaseAuth.instance
                                                          .currentUser?.uid;

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(senderUid)
                                                      .update({
                                                    'friendList':
                                                        FieldValue.arrayUnion(
                                                            [receiverUid]),
                                                  });

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(receiverUid)
                                                      .update({
                                                    'friendList':
                                                        FieldValue.arrayUnion(
                                                            [senderUid]),
                                                  });

                                                  String friendRequestId =
                                                      snapshot
                                                          .data!.docs[index].id;
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'friendrequest')
                                                      .doc(friendRequestId)
                                                      .delete();

                                                  print(
                                                      'Friend request accepted successfully');
                                                  Fluttertoast.showToast(
                                                    msg: 'ตอบรับคำขอเสร็จสิ้น',
                                                  );
                                                } catch (error) {
                                                  print(
                                                      'Error accepting friend request: $error');
                                                }
                                              },
                                              child: Text(
                                                'ยอมรับ',
                                                style:
                                                    GoogleFonts.ibmPlexSansThai(
                                                  fontSize: 12,
                                                  color: const Color.fromARGB(
                                                      255, 229, 228, 228),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            height: 30,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  String friendRequestId =
                                                      snapshot
                                                          .data!.docs[index].id;
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'friendrequest')
                                                      .doc(friendRequestId)
                                                      .delete();

                                                  print(
                                                      'Friend request declined successfully');
                                                  Fluttertoast.showToast(
                                                    msg: 'ปฎิเสธคำขอเสร็จสิ้น',
                                                  );
                                                } catch (error) {
                                                  print(
                                                      'Error declining friend request: $error');
                                                }
                                              },
                                              child: Text(
                                                'ปฎิเสธ',
                                                style:
                                                    GoogleFonts.ibmPlexSansThai(
                                                  fontSize: 12,
                                                  color: const Color.fromARGB(
                                                      255, 229, 228, 228),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
