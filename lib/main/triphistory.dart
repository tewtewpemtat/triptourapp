import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:intl/intl.dart';

class TripHistory extends StatefulWidget {
  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _tripDataList = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchTripList(); // เรียกใช้ method เพื่อดึงข้อมูลทริปตอนเริ่มต้น
  }

  void fetchTripList() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .where('tripJoin', arrayContains: uid)
        .where('tripStatus', isEqualTo: 'กำลังดำเนินการ')
        .get();

    setState(() {
      _tripDataList = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                flex: 7, // Changed flex to 7
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey), // Color of the border
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
              // Expanded(
              //   flex: 1, // หรือไม่ต้องใส่ flex เลย
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 6),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: InkWell(
              //             onTap: () {},
              //             child: Align(
              //               alignment: Alignment.center,
              //               child: Icon(Icons.mail, color: Colors.grey),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        SizedBox(height: 5),
        ListView.builder(
          shrinkWrap: true,
          itemCount:
              _tripDataList.length, // ใช้ _tripDataList แทน snapshot.data!.docs
          itemBuilder: (context, index) {
            return buildTripItem(
                context,
                _tripDataList[
                    index]); // ใช้ _tripDataList แทน snapshot.data!.docs
          },
        ),
      ],
    );
  }

  Widget buildTripItem(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> tripData = document.data() as Map<String, dynamic>;
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    String startDate = dateFormat.format(tripData['tripStartDate'].toDate());
    String endDate = dateFormat.format(tripData['tripEndDate'].toDate());

    bool matchesSearch = false;

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
              MaterialPageRoute(builder: (context) => TripmanagePage()),
            );
          },
          child: Container(
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
                        width: 100.0,
                        height: 140.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 13),
                Expanded(
                  flex: 6,
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
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text('สถานะทริป: ${tripData['tripStatus']}',
                            style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                        Text('วันที่เดินทาง: $startDate - $endDate',
                            style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
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
                              return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Text('ไม่พบข้อมูลผู้ใช้');
                            }
                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>?;

                            if (userData == null) {
                              return Text('ไม่พบข้อมูลผู้ใช้');
                            }

                            return Text('ผู้จัดทริป: ${userData['nickname']}',
                                style:
                                    GoogleFonts.ibmPlexSansThai(fontSize: 12));
                          },
                        ),
                        Text('จำนวนผู้ร่วมทริป: ${tripData['tripLimit']} คน',
                            style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(); // Don't show the item if it doesn't match the search query
    }
  }
}

void main() {
  runApp(TripHistory());
}
