import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class PlaceSum extends StatefulWidget {
  final String? tripUid;

  const PlaceSum({Key? key, this.tripUid}) : super(key: key);

  @override
  _PlaceSumState createState() => _PlaceSumState();
}

class _PlaceSumState extends State<PlaceSum> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .where('placetripid', isEqualTo: widget.tripUid)
          .where('placeadd', isEqualTo: "Yes")
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(''),
          );
        }
        final places = snapshot.data!.docs;
        places.sort((a, b) {
          final aEndTime = a['placetimeend'] as Timestamp;
          final bEndTime = b['placetimeend'] as Timestamp;
          return aEndTime.compareTo(bEndTime);
        });

        return Column(
          children: places.map((place) {
            final placeData = place.data() as Map<String, dynamic>;
            return buildPlaceItem(context, placeData, place);
          }).toList(),
        );
      },
    );
  }

  Widget buildPlaceItem(
      BuildContext context, Map<String, dynamic> placeData, place) {
    String placeName = placeData['placename'];
    String placeAddress = placeData['placeaddress'];
    int maxCharsFirstLine = 17;
    int maxCharsTotal = 30;
    int maxCharsFirstLine2 = 50;
    int maxCharsTotal2 = 60;
    String displayedName = placeName.length > maxCharsFirstLine
        ? (placeName.length > maxCharsTotal
            ? placeName.substring(0, maxCharsFirstLine) + '...'
            : placeName.substring(0, maxCharsFirstLine) +
                '\n' +
                (placeName.length > maxCharsTotal
                    ? placeName.substring(maxCharsFirstLine, maxCharsTotal) +
                        '...'
                    : placeName.substring(maxCharsFirstLine)))
        : placeName;
    String displayedName2 = placeAddress.length > maxCharsFirstLine2
        ? (placeAddress.length > maxCharsTotal2
            ? placeAddress.substring(0, maxCharsFirstLine2) + '...'
            : placeAddress.substring(0, maxCharsFirstLine2) +
                '\n' +
                (placeAddress.length > maxCharsTotal2
                    ? placeAddress.substring(
                            maxCharsFirstLine2, maxCharsTotal2) +
                        '...'
                    : placeAddress.substring(maxCharsFirstLine2)))
        : placeAddress;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 120.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: Stack(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    placeData['placepicUrl'] ??
                        'assets/userplan/userplan_image1.png',
                    width: 120.0,
                    height: 120.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayedName,
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
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
                            placeData['placeprovince'] ?? '',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          displayedName2,
                          style: GoogleFonts.ibmPlexSansThai(fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Color(0xffdb923c),
                              ),
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                'วันเวลาเริ่มต้น',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                DateFormat('dd-MM-yyy HH:mm').format(
                                    (placeData['placetimestart'] as Timestamp)
                                        .toDate()),
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Color(0xffc21111),
                              ),
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                'วันเวลาสิ้นสุด',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                DateFormat('dd-MM-yyy HH:mm').format(
                                    (placeData['placetimeend'] as Timestamp)
                                        .toDate()),
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (placeData['placerun'] == "Start")
            Positioned(
              top: -5,
              right: -5,
              child: InkWell(
                onTap: () {},
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () async {
                      String placeId = place.reference.id;
                      List<String> updatedWhogo = [uid];
                      try {
                        await FirebaseFirestore.instance
                            .collection('places')
                            .doc(placeId)
                            .update({
                          'placetimestart': null,
                          'placetimeend': null,
                          'placeadd': 'No',
                          'placestart': '',
                          'placewhogo': updatedWhogo
                        });

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
                    icon: Icon(Icons.remove),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PlaceSum(),
  ));
}
