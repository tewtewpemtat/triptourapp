import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/TripTimeLine.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TripHistory extends StatefulWidget {
  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ทริปของคุณ',
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              'แสดงทริปของคุณที่กำลังดำเนินการอยู่หรือทริปที่ยังไม่เริ่ม',
              style:
                  GoogleFonts.ibmPlexSansThai(fontSize: 13, color: Colors.grey),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey), // Color of the border
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 5),
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 5),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'ค้นหาทริปของคุณ',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  child: IconButton(
                    // Wrap the Icon with IconButton
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.grey,
                      size: 28,
                    ),
                    onPressed: () {
                      // Your code to handle the tap event
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .where('tripJoin', arrayContains: uid)
                .where('tripStatus',
                    whereIn: ['ยังไม่เริ่มต้น', 'กำลังดำเนินการ']).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('ไม่พบข้อมูลทริป'));
              }

              List<DocumentSnapshot> tripDataList = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tripDataList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> tripData =
                      tripDataList[index].data() as Map<String, dynamic>;
                  // Check if the trip has started and its status is 'Not started yet'
                  if (DateTime.now()
                          .isAfter(tripData['tripStartDate'].toDate()) &&
                      tripData['tripStatus'] == 'ยังไม่เริ่มต้น') {
                    // Update trip status to "In progress"
                    FirebaseFirestore.instance
                        .collection('trips')
                        .doc(tripDataList[index].id)
                        .update({'tripStatus': 'กำลังดำเนินการ'});
                  } else if (DateTime.now()
                          .isAfter(tripData['tripEndDate'].toDate()) &&
                      tripData['tripStatus'] == 'กำลังดำเนินการ') {
                    // Update trip status to "In progress"
                    FirebaseFirestore.instance
                        .collection('trips')
                        .doc(tripDataList[index].id)
                        .update({'tripStatus': 'สิ้นสุด'});
                  }
                  return buildTripItem(
                    context,
                    tripDataList[index],
                    tripDataList[index].id,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  int getTotalParticipants(DocumentSnapshot document) {
    Map<String, dynamic> tripData = document.data() as Map<String, dynamic>;
    List<dynamic> tripJoin = tripData['tripJoin'];
    return tripJoin.length;
  }

  void checkAndUpdateTrips(BuildContext context, String tripUid) async {
    var placesSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

    var tripData = placesSnapshot.data();

    if (tripData != null && // Add null check for tripData
        DateTime.now().isAfter(tripData['tripStartDate'].toDate()) &&
        tripData['tripStatus'] == 'ยังไม่เริ่มต้น') {
      // Update trip status to "In progress"
      FirebaseFirestore.instance
          .collection('trips')
          .doc(tripUid)
          .update({'tripStatus': 'กำลังดำเนินการ'});

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TripmanagePage(tripUid: tripUid)),
      );
    } else if (tripData != null && // Add null check for tripData
        DateTime.now().isAfter(tripData['tripEndDate'].toDate()) &&
        tripData['tripStatus'] == 'กำลังดำเนินการ') {
      // Update trip status to "In progress"
      FirebaseFirestore.instance
          .collection('trips')
          .doc(tripUid)
          .update({'tripStatus': 'สิ้นสุด'});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TripTimeLine()),
      );
      Fluttertoast.showToast(
        msg: "ทริปได้สิ้นสุดไปเเล้ว",
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TripmanagePage(tripUid: tripUid)),
      );
    }
  }

  void _showParticipantsDialog(List<dynamic> participants) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รายชื่อผู้เข้าร่วมทริป'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: participants.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(participants[index])
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('');
                    }
                    if (snapshot.hasError) {
                      return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text('ไม่พบข้อมูลผู้ใช้');
                    }
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    String firstName = userData['firstName'] ?? '';
                    String nickname = userData['nickname'] ?? '';
                    String profileImageUrl = userData['profileImageUrl'] ?? '';
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 30.0,
                        backgroundImage:
                            NetworkImage(userData['profileImageUrl'] ?? ''),
                      ),
                      title: Text(firstName),
                      subtitle: Text(nickname),
                    );
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Widget buildTripItem(
      BuildContext context, DocumentSnapshot document, String tripUid) {
    Map<String, dynamic> tripData = document.data() as Map<String, dynamic>;
    DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    String startDate = dateFormat.format(tripData['tripStartDate'].toDate());
    String endDate = dateFormat.format(tripData['tripEndDate'].toDate());

    bool matchesSearch = false;
    String status = tripData['tripStatus'];
    String statusImage =
        status == 'ยังไม่เริ่มต้น' ? 'assets/green.png' : 'assets/yellow.png';
    if (tripData['tripName'] != null) {
      String fullName = tripData['tripName'].toLowerCase();
      matchesSearch = fullName.contains(_searchQuery);
    }

    if (_searchQuery.isEmpty || matchesSearch) {
      return Material(
        child: InkWell(
          onTap: () {
            checkAndUpdateTrips(context, tripUid);
          },
          child: Container(
            height: 140,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      child: tripData['tripProfileUrl'] != null
                          ? Image.network(
                              tripData['tripProfileUrl'],
                              height: 140.0,
                              fit: BoxFit.cover,
                            )
                          : Placeholder(
                              // สร้าง Placeholder หรือรูปภาพแทนกรณีที่ URL เป็น null
                              fallbackHeight: 140.0,
                              fallbackWidth: double.infinity,
                              color: Colors.grey, // สีพื้นหลังของ Placeholder
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'ชื่อทริป: ${tripData['tripName']}',
                                  style: GoogleFonts.ibmPlexSansThai(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(statusImage, width: 12, height: 12),
                              SizedBox(width: 3),
                              Text(
                                'สถานะ: ${tripData['tripStatus']}',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Color(0xffdb923c),
                                ),
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  'วันเวลาเริ่มต้น',
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  startDate,
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Color(0xffc21111),
                                ),
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  'วันเวลาสิ้นสุด',
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  endDate,
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(tripData['tripCreate'])
                                .get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('กำลังโหลด...');
                              }
                              if (snapshot.hasError) {
                                return Text(
                                    'เกิดข้อผิดพลาด: ${snapshot.error}');
                              }
                              if (!snapshot.hasData || snapshot.data == null) {
                                return Text('ไม่พบข้อมูลผู้ใช้');
                              }
                              var userData = snapshot.data!.data()
                                  as Map<String, dynamic>?;

                              if (userData == null) {
                                return Text('ไม่พบข้อมูลผู้ใช้');
                              }

                              return Text(
                                'ผู้จัดทริป: ${userData['nickname']}',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 3),
                          Container(
                            margin: EdgeInsets.all(0),
                            child: Row(
                              children: [
                                Text(
                                  'จำนวนผู้ร่วมทริป: ${getTotalParticipants(document)} คน',
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  margin: EdgeInsets.all(0),
                                  child: InkWell(
                                    onTap: () {
                                      _showParticipantsDialog(
                                          tripData['tripJoin']);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Icon(
                                        Icons.person,
                                        size: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: TripHistory(),
  ));
}
