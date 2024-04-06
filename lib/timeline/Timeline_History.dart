import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/placetimeline.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:intl/intl.dart';

class TripTimelinePage extends StatefulWidget {
  @override
  _TripTimelineState createState() => _TripTimelineState();
}

class _TripTimelineState extends State<TripTimelinePage> {
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
                'ไทมไลน์ของคุณ',
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
              'แสดงประวัติทริปเเละไทมไลน์แต่ละสถานที่ของคุณ',
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
              ],
            ),
          ),
          SizedBox(height: 5),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .where('tripJoin', arrayContains: uid)
                .where('tripStatus', whereIn: ['สิ้นสุด']).snapshots(),
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

  Widget buildTripItem(
      BuildContext context, DocumentSnapshot document, String tripUid) {
    Map<String, dynamic> tripData = document.data() as Map<String, dynamic>;
    DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    String startDate = dateFormat.format(tripData['tripStartDate'].toDate());
    String endDate = dateFormat.format(tripData['tripEndDate'].toDate());

    bool matchesSearch = false;
    String status = tripData['tripStatus'];
    String statusImage =
        status == 'สิ้นสุด' ? 'assets/red.png' : 'assets/yellow.png';
    if (tripData['tripName'] != null) {
      String fullName = tripData['tripName'].toLowerCase();
      matchesSearch = fullName.contains(_searchQuery);
    }

    if (_searchQuery.isEmpty || matchesSearch) {
      return Material(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Placetimeline(tripUid: tripUid)),
            );
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
                      child: Image.network(
                        tripData['tripProfileUrl'],
                        height: 140.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 13),
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
                          Text(
                            'จำนวนผู้ร่วมทริป: ${getTotalParticipants(document)} คน',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
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
    home: TripTimelinePage(),
  ));
}
