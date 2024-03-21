import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RequestPage extends StatefulWidget {
  @override
  final String? tripUid;

  const RequestPage({Key? key, this.tripUid}) : super(key: key);
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  Widget buildRequestTile(DocumentSnapshot place, DocumentSnapshot userData) {
    var nickname = userData['nickname'] ?? 'Unknown';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text(
          place['placename'],
          style: GoogleFonts.ibmPlexSansThai(
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place['placeaddress'],
              style: GoogleFonts.ibmPlexSansThai(
                fontSize: 12,
              ),
            ),
            Text(
              'ผู้ร้องขอ: $nickname',
              style: GoogleFonts.ibmPlexSansThai(
                fontSize: 15,
              ),
            ),
          ],
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            place['placepicUrl'],
            width: 80, // ปรับค่า width ตามต้องการ
            height: 80, // ปรับค่า height ตามต้องการ
            fit: BoxFit.cover,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            // อัปเดตค่า placestatus เมื่อคลิกที่ไอคอน "add"
            FirebaseFirestore.instance
                .collection('places')
                .doc(place.id)
                .update({'placestatus': 'Added'}).then((value) {
              print('เปลี่ยนสถานะเป็น Added เรียบร้อยแล้ว');
              Fluttertoast.showToast(msg: 'เพิ่มสถานที่นี้เข้าไปบนทริปเเล้ว');
            }).catchError((error) {
              print('เกิดข้อผิดพลาดในการเปลี่ยนสถานะ: $error');
            });
          },
        ),
        onTap: () {
          // Handle tap event
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[350],
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('คำร้องขอ'),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('places')
              .where('placetripid', isEqualTo: widget.tripUid)
              .where('placestatus', isEqualTo: 'Wait')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('ไม่พบสถานที่'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var place = snapshot.data!.docs[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(place['useruid'])
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: Text(place['placename']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place['placeaddress']),
                            Text('กำลังโหลดข้อมูลผู้ร้องขอ...'),
                          ],
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            place['placepicUrl'],
                            width: 100, // ปรับค่า width ตามต้องการ
                            height: 100, // ปรับค่า height ตามต้องการ
                            fit: BoxFit.cover,
                          ),
                        ),
                        trailing: Icon(Icons.add),
                      );
                    }
                    if (userSnapshot.hasError) {
                      return ListTile(
                        title: Text(place['placename']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place['placeaddress']),
                            Text('ไม่สามารถโหลดข้อมูลผู้ร้องขอได้'),
                          ],
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            place['placepicUrl'],
                            width: 100, // ปรับค่า width ตามต้องการ
                            height: 100, // ปรับค่า height ตามต้องการ
                            fit: BoxFit.cover,
                          ),
                        ),
                        trailing: Icon(Icons.add),
                      );
                    }
                    var userData = userSnapshot.data;
                    if (userData == null) {
                      return ListTile(
                        title: Text(place['placename']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place['placeaddress']),
                            Text('ไม่พบข้อมูลผู้ร้องขอ'),
                          ],
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            place['placepicUrl'],
                            width: 100, // ปรับค่า width ตามต้องการ
                            height: 100, // ปรับค่า height ตามต้องการ
                            fit: BoxFit.cover,
                          ),
                        ),
                        trailing: Icon(Icons.add),
                      );
                    }
                    return buildRequestTile(place, userData);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RequestPage(),
  ));
}
