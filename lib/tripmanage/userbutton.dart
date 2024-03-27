import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/groupchat.dart';
import 'package:triptourapp/main.dart';
import 'package:triptourapp/requestplace.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Userbutton extends StatefulWidget {
  @override
  final String? tripUid;
  const Userbutton({Key? key, this.tripUid}) : super(key: key);

  UserbuttonState createState() => UserbuttonState();
}

class UserbuttonState extends State<Userbutton> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _removeUserFromTrip() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripUid)
          .update({
        'tripJoin': FieldValue.arrayRemove([uid]),
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripUid)
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
        try {
          DateTime now = DateTime.now();
          if (tripData != null) {
            DateTime tripStartDate = tripData['tripStartDate'].toDate();
            if (now.isAfter(tripStartDate) ||
                now.isAtSameMomentAs(tripStartDate)) {
              // เปรียบเทียบเวลาปัจจุบันกับเวลาเริ่มต้นของทริป
              FirebaseFirestore.instance
                  .collection('trips')
                  .doc(widget.tripUid)
                  .update({'tripStatus': 'กำลังดำเนินการ'});
              print('Trip status updated successfully');
            } else {
              print('Trip has not started yet');
            }
          }
        } catch (e) {
          print('Error updating trip status: $e');
        }

        if (tripData != null) {
          var tripStatus = tripData['tripStatus'];

          if (tripStatus == 'กำลังดำเนินการ') {
            // หาก tripStatus เป็น "กำลังดำเนินการ" แสดงว่าต้องซ่อนปุ่ม
            return Container(
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'แผนการเดินทาง',
                            style: GoogleFonts.ibmPlexSansThai(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _removeUserFromTrip();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.red, // กำหนดสีพื้นหลังเป็นสีแดง
                            primary:
                                Colors.white, // กำหนดสีของตัวอักษรเป็นสีขาว
                          ),
                          child: Text(
                            'ออกจากทริป',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              // สามารถกำหนดสีข้อความเพิ่มเติมได้ที่นี่ถ้าต้องการ
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupScreenPage(
                                    tripUid: widget.tripUid ?? ''),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // สีพื้นหลังของปุ่ม
                            onPrimary: Colors.black, // สีขอบตัวอักษร
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat), // รูปไอคอนแชท
                              SizedBox(
                                  width:
                                      8), // ระยะห่างระหว่างไอคอนแชทและข้อความ
                              Text(
                                'แชทกลุ่ม',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            // หาก tripStatus ไม่เป็น "กำลังดำเนินการ" แสดงว่าต้องแสดงปุ่ม
            return Container(
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'แผนการเดินทาง',
                            style: GoogleFonts.ibmPlexSansThai(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _removeUserFromTrip();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.red, // กำหนดสีพื้นหลังเป็นสีแดง
                            primary:
                                Colors.white, // กำหนดสีของตัวอักษรเป็นสีขาว
                          ),
                          child: Text(
                            'ออกจากทริป',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              // สามารถกำหนดสีข้อความเพิ่มเติมได้ที่นี่ถ้าต้องการ
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupScreenPage(
                                    tripUid: widget.tripUid ?? ''),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // สีพื้นหลังของปุ่ม
                            onPrimary: Colors.black, // สีขอบตัวอักษร
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat), // รูปไอคอนแชท
                              SizedBox(
                                  width:
                                      8), // ระยะห่างระหว่างไอคอนแชทและข้อความ
                              Text(
                                'แชทกลุ่ม',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // สีพื้นหลังของปุ่ม
                            onPrimary: Colors.black, // สีขอบตัวอักษร
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mail),

                              // รูปไอคอนแชท
                              SizedBox(
                                  width:
                                      8), // ระยะห่างระหว่างไอคอนแชทและข้อความ
                              Text(
                                'ร้องขอสถานที่',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                ],
              ),
            );
          }
        } else {
          return Container();
        }
      },
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Userbutton(),
    ),
  );
}
