import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/edittrip.dart';
import 'package:triptourapp/main.dart';

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
          // หรือส่วนที่คุณต้องการทำต่อไป
        }

        var tripData = snapshot.data?.data() as Map<String, dynamic>?;
        if (tripData != null) {
          bool isTripCreator = uid == tripData['tripCreate'];

          DateFormat dateFormat =
              DateFormat('\td\tMMMM\tyyyy  -  เวลา  HH:mm', 'th');
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

          // ตรวจสอบสถานะของทริปเพื่อกำหนดรูปภาพ
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
            margin: EdgeInsets.all(0.0),
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(0.0),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ชื่อทริป: ${tripData['tripName']}',
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isTripCreator &&
                        tripData['tripStatus'] ==
                            'ยังไม่เริ่มต้น') // เพิ่มการตรวจสอบนี้
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
                Row(
                  children: [
                    Text(
                      'จำนวนผู้ร่วมทริป: ${getTotalParticipants(tripData)} คน ',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Image.asset(statusImage,
                        width: 14, height: 14), // ใช้รูปภาพตามสถานะ
                    Text(
                      '\t สถานะ: ${tripData['tripStatus']}',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  'เริ่มต้น $thaiStartDate',
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'สิ้นสุด $thaiEndDate',
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
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
                          'ผู้จัดทริป: ${userData['nickname']} \t\t\t',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    Text(
                      '\t\t ผู้ร่วมทริปสูงสุด : ${tripData['tripLimit']}',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
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
