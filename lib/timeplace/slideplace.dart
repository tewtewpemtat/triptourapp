import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocoding/geocoding.dart';

class SlidePlace extends StatefulWidget {
  final String? tripUid;

  const SlidePlace({Key? key, this.tripUid}) : super(key: key);

  @override
  _SlidePlaceState createState() => _SlidePlaceState();
}

class _SlidePlaceState extends State<SlidePlace> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: Text('No places found.'),
            );
          }
        },
      ),
    );
  }

  Widget buildTripItem(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: InkWell(
        onTap: () {
          // Handle tap action
        },
        child: Container(
          padding: EdgeInsets.all(5.0),
          child: Row(
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
                        data['placename'], // อ้างอิงชื่อสถานที่จาก Firestore
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      SizedBox(width: 5),
                      Text(
                        data[
                            'placeaddress'], // อ้างอิงที่อยู่ของสถานที่จาก Firestore
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: SlidePlace(),
    ),
  ));
}
