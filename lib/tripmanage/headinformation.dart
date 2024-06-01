import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/edittrip.dart';

class InformationPage extends StatelessWidget {
  final String? tripUid;

  const InformationPage({Key? key, this.tripUid}) : super(key: key);

  int getTotalParticipants(Map<String, dynamic> tripData) {
    List<dynamic> tripJoin = tripData['tripJoin'];
    return tripJoin.length;
  }

  String formatThaiMonthYear(int month) {
    final List<String> thaiMonths = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    if (month >= 1 && month <= 12) {
      return '${thaiMonths[month - 1]}';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .doc(tripUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Container();
        }

        var tripData = snapshot.data?.data() as Map<String, dynamic>?;
        if (tripData != null) {
          bool isTripCreator = uid == tripData['tripCreate'];

          DateFormat dateFormat = DateFormat('\td\tMMMM\tyyyy, HH:mm', 'th');
          DateTime startDateTH = tripData['tripStartDate'].toDate();
          DateTime endDateTH = tripData['tripEndDate'].toDate();
          String thaiStartDate = dateFormat.format(DateTime(
              startDateTH.year,
              startDateTH.month,
              startDateTH.day,
              startDateTH.hour,
              startDateTH.minute));
          String thaiEndDate = dateFormat.format(DateTime(
              endDateTH.year,
              endDateTH.month,
              endDateTH.day,
              endDateTH.hour,
              endDateTH.minute));

          String status = tripData['tripStatus'];
          String statusImage;
          if (status == 'ยังไม่เริ่มต้น') {
            statusImage = 'assets/green.png';
          } else if (status == 'กำลังดำเนินการ') {
            statusImage = 'assets/yellow.png';
          } else {
            statusImage = 'assets/red.png';
          }

          return Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 254, 254, 254),
              borderRadius: BorderRadius.circular(6.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    child: tripData['tripProfileUrl'] != null
                        ? Image.network(
                            tripData['tripProfileUrl'],
                            height: 180.0,
                            fit: BoxFit.cover,
                          )
                        : Placeholder(
                            fallbackHeight: 140.0,
                            fallbackWidth: double.infinity,
                            color: Colors.grey,
                          ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ชื่อทริป: ${tripData['tripName']}',
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isTripCreator &&
                        tripData['tripStatus'] == 'ยังไม่เริ่มต้น')
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditTrip(tripUid: tripUid)),
                          );
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Image.asset('assets/pencil.png',
                              width: 18, height: 18),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Image.asset('assets/travel1.png', width: 15, height: 15),
                    SizedBox(
                      width: 8,
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(tripData['tripCreate'])
                          .get(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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

                        return Text(
                          'ผู้จัดทริป : ${userData['nickname']} \t\t\t',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Image.asset(statusImage, width: 13, height: 13),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        '${tripData['tripStatus']}',
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Image.asset('assets/travel2.png', width: 15, height: 15),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'จำนวนผู้ร่วมทริป: ${getTotalParticipants(tripData)} คน ',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Image.asset('assets/travel3.png', width: 15, height: 15),
                    Text(
                      '\t\tผู้ร่วมทริปสูงสุด : ${tripData['tripLimit']}',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Image.asset('assets/greenflag.png', width: 18, height: 18),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'เริ่มต้น $thaiStartDate',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Image.asset('assets/redflag.png', width: 18, height: 18),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'สิ้นสุด  $thaiEndDate',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InformationPage(),
  ));
}
