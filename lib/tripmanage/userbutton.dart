import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/addplaceuser.dart';
import 'package:triptourapp/groupchat.dart';
import 'package:triptourapp/main.dart';
import 'package:triptourapp/requestplace.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      try {
        DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripUid)
            .get();

        if (!tripSnapshot.exists) {
          print('Trip not found');
          return;
        }
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
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('placemeet')
            .where('placetripid', isEqualTo: widget.tripUid)
            .where('useruid', isEqualTo: uid)
            .get();

        // ลบรูปภาพใน Firebase Storage และลบเอกสารที่พบเจอ
        querySnapshot.docs.forEach((document) async {
          String placePicUrl = document['placepicUrl'];
          // ลบรูปภาพใน Firebase Storage
          Reference ref = FirebaseStorage.instance.refFromURL(placePicUrl);
          await ref.delete();
          // ลบเอกสารที่พบเจอออกจาก Firestore
          await FirebaseFirestore.instance
              .collection('placemeet')
              .doc(document.id)
              .delete();
        });
        QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
            .collection('interest')
            .where('placetripid', isEqualTo: widget.tripUid)
            .where('useruid', isEqualTo: uid)
            .get();

        // ลบรูปภาพใน Firebase Storage และลบเอกสารที่พบเจอ
        querySnapshot2.docs.forEach((document) async {
          String placePicUrl = document['placepicUrl'];
          // ลบรูปภาพใน Firebase Storage
          Reference ref = FirebaseStorage.instance.refFromURL(placePicUrl);
          await ref.delete();
          // ลบเอกสารที่พบเจอออกจาก Firestore
          await FirebaseFirestore.instance
              .collection('interest')
              .doc(document.id)
              .delete();
        });

        QuerySnapshot querySnapshot3 = await FirebaseFirestore.instance
            .collection('groupmessages')
            .where('tripChatUid', isEqualTo: widget.tripUid)
            .where('senderUid', isEqualTo: uid)
            .get();

        // ลบรูปภาพใน Firebase Storage และลบเอกสารที่พบเจอ
        querySnapshot3.docs.forEach((document) async {
          await FirebaseFirestore.instance
              .collection('groupmessages')
              .doc(document.id)
              .delete();
        });
        QuerySnapshot querySnapshot4 = await FirebaseFirestore.instance
            .collection('places')
            .where('placetripid', isEqualTo: widget.tripUid)
            .get();

        querySnapshot4.docs.forEach((document) async {
          if (document.exists) {
            Map<String, dynamic>? data =
                document.data() as Map<String, dynamic>?;
            if (data != null) {
              List<dynamic> placeWhogo = data['placewhogo'];
              if (placeWhogo != null) {
                if (placeWhogo.contains(uid)) {
                  placeWhogo.remove(uid);
                  await FirebaseFirestore.instance
                      .collection('places')
                      .doc(document.id)
                      .update({'placewhogo': placeWhogo});
                }
              }
            }
          }
        });
        QuerySnapshot querySnapshot5 = await FirebaseFirestore.instance
            .collection('timeline')
            .where('placetripid', isEqualTo: widget.tripUid)
            .where('userid', isEqualTo: uid)
            .get();

        querySnapshot5.docs.forEach((document) async {
          await FirebaseFirestore.instance
              .collection('timeline')
              .doc(document.id)
              .delete();
        });

        Fluttertoast.showToast(msg: 'ออกจากทริปเรียบร้อยเเล้ว');
      } catch (e) {
        print('Error: $e'); // แสดง error message ใน console
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาดในการออกทริป');
      }
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
            DateTime tripEndDate = tripData['tripEndDate'].toDate();
            if (now.isAfter(tripStartDate) && now.isBefore(tripEndDate)) {
              // เปรียบเทียบเวลาปัจจุบันกับเวลาเริ่มต้นของทริป
              FirebaseFirestore.instance
                  .collection('trips')
                  .doc(widget.tripUid)
                  .update({'tripStatus': 'กำลังดำเนินการ'});
              print('Trip status updated successfully');
            } else if (now.isAfter(tripEndDate)) {
              // เปรียบเทียบเวลาปัจจุบันกับเวลาเริ่มต้นของทริป
              FirebaseFirestore.instance
                  .collection('trips')
                  .doc(widget.tripUid)
                  .update({'tripStatus': 'สิ้นสุด'});
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
                                builder: (context) =>
                                    (AddPage(tripUid: widget.tripUid)),
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
