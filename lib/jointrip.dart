import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/main.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MaterialApp(
    home: JoinTripPage(),
  ));
}

class JoinTripPage extends StatefulWidget {
  @override
  _JoinTripPageState createState() => _JoinTripPageState();
}

class _JoinTripPageState extends State<JoinTripPage> {
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
  late List<String> friendList = []; // เพิ่มตัวแปร friendList ที่นี่

  void acceptRequest(String requestId) {
    // โค้ดสำหรับยอมรับคำเชิญ
  }

  void declineRequest(String requestId) {
    // โค้ดสำหรับปฏิเสธคำเชิญ
  }
  @override
  void initState() {
    super.initState();
    fetchFriendList(); // เรียกใช้เมธอดเมื่อโหลดหน้าเสร็จสิ้น
  }

  void fetchFriendList() async {
    try {
      DocumentSnapshot userDataSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(myUid).get();

      if (userDataSnapshot.exists) {
        Map<String, dynamic>? userData =
            userDataSnapshot.data() as Map<String, dynamic>?;

        if (userData != null &&
            userData['friendList'] != null &&
            (userData['friendList'] as Iterable).isNotEmpty) {
          setState(() {
            friendList = List<String>.from(userData['friendList']);
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "ตอบรับคำเชิญเพื่อเข้าร่วมทริป",
          style: GoogleFonts.ibmPlexSansThai(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripmanagePage(),
              ),
            );
          },
          child: Container(
            color: Colors.white, // สีพื้นหลังของหน้า
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black, // สีของเส้นกรอบ
                      width: 1.0, // ความหนาของเส้นกรอบ
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('triprequest')
                        .where('senderUid', whereIn: friendList)
                        .where('receiverUid', isEqualTo: myUid)
                        .where('status', isEqualTo: 'Waiting')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Text('ไม่มีคำเชิญที่รอการตอบรับ');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var request = snapshot.data!.docs[index];
                          return ListTile(
                            title: Text('คำเชิญจาก: ${request['senderUid']}'),
                            subtitle: Text('สถานะ: ${request['status']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    acceptRequest(request.id);
                                  },
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(
                                        Size(20, 10)), // กำหนดขนาดของปุ่ม
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromARGB(255, 255, 156,
                                            8)), // กำหนดสีพื้นหลังของปุ่ม
                                  ),
                                  child: Text(
                                    'ยอมรับ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    declineRequest(request.id);
                                  },
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(
                                        Size(20, 10)), // กำหนดขนาดของปุ่ม
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromARGB(255, 255, 156,
                                            8)), // กำหนดสีพื้นหลังของปุ่ม
                                  ),
                                  child: Text(
                                    'ปฏิเสธ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
