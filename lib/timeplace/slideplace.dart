import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './slidetime.dart';

class SlidePlace extends StatefulWidget {
  final String? tripUid;

  const SlidePlace({Key? key, this.tripUid}) : super(key: key);

  @override
  _SlidePlaceState createState() => _SlidePlaceState();
}

class _SlidePlaceState extends State<SlidePlace> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;

  String? selectedPlaceUid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 140.0,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('places')
                .where('placetripid', isEqualTo: widget.tripUid)
                .where('placestatus', isEqualTo: 'Added')
                .where('placeadd', isEqualTo: 'No')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(''),
                );
              }
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return PageView(
                  children: snapshot.data!.docs.map((document) {
                    return buildTripItem(context, document);
                  }).toList(),
                  controller: PageController(
                    initialPage: _findInitialPageIndex(snapshot.data!.docs),
                  ),
                );
              } else {
                return Center(
                  child: Text('ไม่พบสถานที่'),
                );
              }
            },
          ),
        ),
        SlideTime(selectedPlaceUid: selectedPlaceUid),
      ],
    );
  }

  int _findInitialPageIndex(List<DocumentSnapshot> docs) {
    if (selectedPlaceUid != null) {
      for (int i = 0; i < docs.length; i++) {
        if (docs[i].id == selectedPlaceUid) {
          return i;
        }
      }
    }
    return 0;
  }

  Widget buildTripItem(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String placeName = data['placename'];
    String placeAddress = data['placeaddress'];
    int maxCharsFirstLine = 16;
    int maxCharsTotal = 30;
    int maxCharsFirstLine2 = 60;
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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: InkWell(
          onTap: () {
            setState(() {
              selectedPlaceUid = document.id;
            });
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
                                : 'assets/trips.jpg',
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
                      child: SingleChildScrollView(
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
                                displayedName2,
                                style:
                                    GoogleFonts.ibmPlexSansThai(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -5,
                  right: -5,
                  child: IconButton(
                    onPressed: () async {
                      String placeId = document.id;
                      String placeName = data['placename'];
                      String imageUrl = data['placepicUrl'];

                      try {
                        await FirebaseFirestore.instance
                            .collection('places')
                            .doc(placeId)
                            .delete();

                        Reference imageRef =
                            FirebaseStorage.instance.refFromURL(imageUrl);
                        await imageRef.delete();

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
