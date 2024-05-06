import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/createtrip.dart';
import 'package:triptourapp/jointrip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripButtons extends StatelessWidget {
  @override
  String? myUid = FirebaseAuth.instance.currentUser?.uid;

  Stream<int> countUnreadMessages() async* {
    try {
      final collection = FirebaseFirestore.instance.collection('triprequest');

      // Stream for unread messages where current user is the receiver
      final stream = collection
          .where('receiverUid', isEqualTo: myUid)
          .where('status', isEqualTo: 'Waiting')
          .snapshots();

      await for (QuerySnapshot querySnapshot in stream) {
        yield querySnapshot.size;
      }
    } catch (e) {
      print('Error counting unread messages: $e');
      yield 0;
    }
  }

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.all(10), // ระยะห่างระหว่างปุ่ม
          child: Align(
            alignment: Alignment.centerLeft, // จัดตำแหน่งข้อความไปทางซ้าย

            child: Text(
              'สร้างทริปของคุณ',
              style: GoogleFonts.ibmPlexSansThai(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 10,
          ), // Adjust the values as needed
          child: Text(
            'สร้างทริปหรือเข้าร่วมทริปเพื่อร่วมเดินทางกับเพื่อนๆ',
            style:
                GoogleFonts.ibmPlexSansThai(fontSize: 13, color: Colors.grey),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffdb923c),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTripPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xffdb923c), // ให้สีปุ่มเท่ากับสีของ Container
              padding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'สร้างทริป',
              style: GoogleFonts.ibmPlexSansThai(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffdb923c),
          ),
          child: ElevatedButton(
            onPressed: () {
              // ไปยังหน้าเข้าร่วมทริป
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JoinTripPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Color(
                  0xffdb923c), // ให้สีเหมือนกับสีของ Container ที่ใช้ในการสร้างทริป
              padding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'เข้าร่วมทริป',
                  style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5),
                StreamBuilder<int>(
                  stream: countUnreadMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    int unreadCount = snapshot.data ?? 0;
                    return unreadCount != 0
                        ? Container(
                            width: 28.0, // ขนาดของวงกลม
                            height: 30.0, // ขนาดของวงกลม
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Color.fromARGB(255, 251, 2, 2), // สีของวงกลม
                            ),
                            child: Center(
                              child: Text(
                                unreadCount
                                    .toString(), // จำนวนข้อความที่ยังไม่ได้อ่าน
                                style: TextStyle(
                                  color: Colors.white, // สีของตัวเลข
                                  fontSize: 16.0, // ขนาดตัวเลข
                                ),
                              ),
                            ),
                          )
                        : Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: TripButtons(),
        ),
      ),
    ),
  );
}
