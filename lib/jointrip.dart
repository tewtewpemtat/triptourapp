import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/main.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MaterialApp(
    home: JoinTripPage(),
  ));
}

class JoinTripPage extends StatefulWidget {
  @override
  _JoinTripPageState createState() => _JoinTripPageState();
}

class _JoinTripPageState extends State<JoinTripPage> {
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
  late List<String> friendList = [];

  void acceptRequest(String requestId) async {
    try {
      DocumentSnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('triprequest')
          .doc(requestId)
          .get();
      if (requestSnapshot.exists) {
        var requestData = requestSnapshot.data() as Map<String, dynamic>;
        String tripUid = requestData['tripUid'];
        String senderUid = requestData['senderUid'];
        String receiverUid = requestData['receiverUid'];

        // Retrieve trip data to get tripLimit
        DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .doc(tripUid)
            .get();
        if (tripSnapshot.exists) {
          var tripData = tripSnapshot.data() as Map<String, dynamic>;
          int tripLimit = tripData['tripLimit'];

          // Check if trip is full
          List<dynamic> tripJoin = tripData['tripJoin'] ?? [];
          if (tripJoin.length >= tripLimit) {
            // Trip is full, notify and remove request
            Fluttertoast.showToast(msg: 'ทริปนี้เต็มเเล้ว');
            await FirebaseFirestore.instance
                .collection('triprequest')
                .doc(requestId)
                .delete();
          } else {
            // Trip is not full, add user to tripJoin and remove request
            tripJoin.add(receiverUid);
            await FirebaseFirestore.instance
                .collection('trips')
                .doc(tripUid)
                .update({'tripJoin': tripJoin});
            await FirebaseFirestore.instance
                .collection('triprequest')
                .doc(requestId)
                .delete();
            Fluttertoast.showToast(msg: 'เข้าร่วมทริปสำเร็จ');
          }
        }
      }
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  void declineRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('triprequest')
          .doc(requestId)
          .delete();
    } catch (e) {
      print('Error declining request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFriendList();
  }

  void fetchFriendList() async {
    try {
      DocumentSnapshot userDataSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(myUid).get();

      if (userDataSnapshot.exists) {
        Map<String, dynamic>? userData =
            userDataSnapshot.data() as Map<String, dynamic>?;

        if (userData != null &&
            userData['friendList'] != null &&
            (userData['friendList'] as Iterable).isNotEmpty) {
          setState(() {
            friendList = List<String>.from(userData['friendList']);
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<String> fetchSenderProfileImageUrl(String senderUid) async {
    try {
      DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderUid)
          .get();
      if (senderSnapshot.exists) {
        return senderSnapshot['profileImageUrl'];
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching sender profile image URL: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        title: Text(
          "คำเชิญทริป",
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
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('triprequest')
                    .where('senderUid',
                        whereIn:
                            friendList.isNotEmpty ? friendList : ['dummyValue'])
                    .where('receiverUid', isEqualTo: myUid)
                    .where('status', isEqualTo: 'Waiting')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('');
                  }
                  if (snapshot.hasError) {
                    return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Text('ไม่มีคำเชิญที่รอการตอบรับ');
                  }
                  return Column(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      var request = document.data() as Map<String, dynamic>;
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: FutureBuilder(
                          future:
                              fetchSenderProfileImageUrl(request['senderUid']),
                          builder:
                              (context, AsyncSnapshot<String> urlSnapshot) {
                            if (urlSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (urlSnapshot.hasError) {
                              return Text(
                                  'เกิดข้อผิดพลาด: ${urlSnapshot.error}');
                            }
                            return ListTile(
                              leading: ClipOval(
                                child: Image.network(
                                  urlSnapshot.data ?? 'URL ของรูปโปรไฟล์',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(request['senderUid'])
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot>
                                        userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (userSnapshot.hasError) {
                                    return Text(
                                        'เกิดข้อผิดพลาด: ${userSnapshot.error}');
                                  }
                                  var userData = userSnapshot.data!.data()
                                      as Map<String, dynamic>;
                                  return Text(
                                      'คำเชิญจาก: ${userData['nickname']}');
                                },
                              ),
                              subtitle: FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('trips')
                                    .doc(request['tripUid'])
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot>
                                        tripSnapshot) {
                                  if (tripSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (tripSnapshot.hasError) {
                                    return Text(
                                        'เกิดข้อผิดพลาด: ${tripSnapshot.error}');
                                  }
                                  var tripData = tripSnapshot.data!.data()
                                      as Map<String, dynamic>;
                                  String tripName = tripData['tripName'];
                                  String tripCreatorUid =
                                      tripData['tripCreate'];

                                  return FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(tripCreatorUid)
                                        .get(),
                                    builder: (context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            userSnapshot) {
                                      if (userSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }
                                      if (userSnapshot.hasError) {
                                        return Text(
                                            'เกิดข้อผิดพลาด: ${userSnapshot.error}');
                                      }
                                      var userData = userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                      String tripCreatorName =
                                          userData['nickname'];

                                      return Text('ชื่อทริป: $tripName ');
                                    },
                                  );
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      acceptRequest(document.id);
                                    },
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(
                                          Size(20, 10)),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color.fromARGB(255, 255, 156, 8)),
                                    ),
                                    child: Text(
                                      'ยอมรับ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  TextButton(
                                    onPressed: () {
                                      declineRequest(document.id);
                                    },
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(
                                          Size(20, 10)),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color.fromARGB(255, 255, 156, 8)),
                                    ),
                                    child: Text(
                                      'ปฏิเสธ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
