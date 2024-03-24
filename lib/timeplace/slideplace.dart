import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './slidetime.dart';

class SlidePlace extends StatefulWidget {
  final String? tripUid;

  const SlidePlace({Key? key, this.tripUid}) : super(key: key);

  @override
  _SlidePlaceState createState() => _SlidePlaceState();
}

class _SlidePlaceState extends State<SlidePlace> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;

  String? selectedPlaceUid; // เพิ่มตัวแปรสำหรับเก็บ UID ที่เลือก

  void updateSelectedPlaceUid(String uid) {
    setState(() {
      selectedPlaceUid = uid; // อัปเดตค่า UID
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 140.0,
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('places')
                .where('placetripid', isEqualTo: widget.tripUid)
                .where('placestatus', isEqualTo: 'Added')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return PageView(
                  children: snapshot.data!.docs.map((document) {
                    return buildTripItem(context, document);
                  }).toList(),
                );
              } else {
                return Center(
                  child: Text('ไม่พบสถานที่'),
                );
              }
            },
          ),
        ),
        SlideTime(
            selectedPlaceUid:
                selectedPlaceUid), // ส่งค่า UID ไปยัง SlideTime widget
      ],
    );
  }

  Widget buildTripItem(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String placeName = data['placename'];
    int maxChars = 16;
    String displayedName = placeName.length > maxChars
        ? placeName.substring(0, maxChars) +
            '\n' +
            placeName.substring(maxChars)
        : placeName;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: InkWell(
          onTap: () {
            updateSelectedPlaceUid(
                document.id); // เรียกใช้ฟังก์ชันเพื่ออัปเดตค่า UID
          },
          child: Container(
            padding: EdgeInsets.all(5.0),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            data['placepicUrl'] != null
                                ? data['placepicUrl']
                                : 'assets/cat.jpg',
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayedName,
                              style: GoogleFonts.ibmPlexSansThai(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                                color: Color(0xFF1E30D7),
                              ),
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                data['placeprovince'],
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              data['placeaddress'],
                              style: GoogleFonts.ibmPlexSansThai(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () async {
                      String placeId = document.id;
                      String placeName = data['placename'];
                      String tripId = data['placetripid'];
                      String imageUrl = data['placepicUrl'];

                      try {
                        await FirebaseFirestore.instance
                            .collection('places')
                            .doc(placeId)
                            .delete();

                        if (imageUrl != null) {
                          Reference imageRef =
                              FirebaseStorage.instance.refFromURL(imageUrl);
                          await imageRef.delete();
                        }

                        Fluttertoast.showToast(msg: 'ลบสถานที่สำเร็จ');
                        setState(() {});
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error deleting $placeName: $error')),
                        );
                      }
                    },
                    icon: Icon(Icons.delete),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
