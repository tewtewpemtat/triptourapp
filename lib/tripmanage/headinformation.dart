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

          DateFormat dateFormat = DateFormat('dd/MM/yyyy');
          String startDate =
              dateFormat.format(tripData['tripStartDate'].toDate());
          String endDate = dateFormat.format(tripData['tripEndDate'].toDate());
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
                            'กำลังดำเนินการ') // เพิ่มการตรวจสอบนี้
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
                      style: GoogleFonts.ibmPlexSansThai(fontSize: 16),
                    ),
                    Image.asset('assets/green.png', width: 14, height: 14),
                    Text('\t สถานะ: ${tripData['tripStatus']}',
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 16)),
                  ],
                ),
                Text('วันที่เดินทาง: $startDate - $endDate',
                    style: GoogleFonts.ibmPlexSansThai(fontSize: 16)),
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
                            style: GoogleFonts.ibmPlexSansThai(fontSize: 16));
                      },
                    ),
                    Text('ผู้ร่วมทริปสูงสุด : ${tripData['tripLimit']}',
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 16)),
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
