import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/addplace.dart';
import 'package:triptourapp/groupchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/main.dart';
import 'package:triptourapp/tripmanage.dart';
import '../timeplace.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HeadButton extends StatefulWidget {
  @override
  _HeadButtonState createState() => _HeadButtonState();
  final String? tripUid;
  const HeadButton({Key? key, this.tripUid}) : super(key: key);
}

final String tripUidsend = 'Uid';
void cancelTrip(BuildContext context, String tripUid) async {
  try {
    DocumentSnapshot tripSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

    if (!tripSnapshot.exists) {
      print('Trip not found');
      return;
    }

    List<dynamic> tripJoin = tripSnapshot['tripJoin'];

    if (tripJoin.length > 1) {
      await Fluttertoast.showToast(
          msg: 'จำนวนผู้ร่วมต้องไม่เกิน 1 คนจึงจะสามารถลบทริปได้');
      return;
    }
    QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection('placemeet')
        .where('placetripid', isEqualTo: tripUid)
        .get();

    // ลบรูปภาพใน Firebase Storage และลบเอกสารที่พบเจอ
    querySnapshot2.docs.forEach((document) async {
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

    QuerySnapshot querySnapshot3 = await FirebaseFirestore.instance
        .collection('interest')
        .where('placetripid', isEqualTo: tripUid)
        .get();

    // ลบรูปภาพใน Firebase Storage และลบเอกสารที่พบเจอ
    querySnapshot3.docs.forEach((document) async {
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

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('places')
        .where('placetripid', isEqualTo: tripUid)
        .get();

    // ลบรูปภาพใน Firebase Storage และลบเอกสารที่พบเจอ
    querySnapshot.docs.forEach((document) async {
      String placePicUrl = document['placepicUrl'];
      // ลบรูปภาพใน Firebase Storage
      Reference ref = FirebaseStorage.instance.refFromURL(placePicUrl);
      await ref.delete();
      // ลบเอกสารที่พบเจอออกจาก Firestore
      await FirebaseFirestore.instance
          .collection('places')
          .doc(document.id)
          .delete();
    });

    // ลบภาพใน Firebase Storage
    String tripProfileUrl = tripSnapshot['tripProfileUrl'];
    Reference ref = FirebaseStorage.instance.refFromURL(tripProfileUrl);
    await ref.delete();

    // ลบเอกสารที่อ้างอิงถึงทริปออกจาก Firestore
    await FirebaseFirestore.instance.collection('trips').doc(tripUid).delete();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyApp(),
      ),
    );
    Fluttertoast.showToast(msg: 'ลบทริปสำเร็จ');
    print('Trip canceled successfully');
  } catch (e) {
    print('Error canceling trip: $e');
  }
}

String? uid = FirebaseAuth.instance.currentUser?.uid;

class _HeadButtonState extends State<HeadButton> {
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
                            cancelTrip(context, widget.tripUid.toString());
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.red, // กำหนดสีพื้นหลังเป็นสีแดง
                            primary:
                                Colors.white, // กำหนดสีของตัวอักษรเป็นสีขาว
                          ),
                          child: Text(
                            'ยกเลิกทริป',
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
                            cancelTrip(context, widget.tripUid.toString());
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.red, // กำหนดสีพื้นหลังเป็นสีแดง
                            primary:
                                Colors.white, // กำหนดสีของตัวอักษรเป็นสีขาว
                          ),
                          child: Text(
                            'ยกเลิกทริป',
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
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddPage(tripUid: widget.tripUid ?? '')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.black,
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on), // รูปไอคอนแชท
                              SizedBox(width: 2),
                              Text(
                                'เพิ่มสถานที่',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TimePlacePage(tripUid: widget.tripUid)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.black,
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time), // รูปไอคอนแชท
                              SizedBox(width: 2),
                              Text(
                                'กำหนดเวลาสถานที่',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
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
      home: HeadButton(),
    ),
  );
}
