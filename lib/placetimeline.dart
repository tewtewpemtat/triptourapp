import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:triptourapp/TripTimeLine.dart';
import 'package:triptourapp/placedetailtimeline.dart';

class Placetimeline extends StatefulWidget {
  final String? tripUid;
  const Placetimeline({Key? key, this.tripUid}) : super(key: key);
  _PlacetimelineState createState() => _PlacetimelineState();
}

class _PlacetimelineState extends State<Placetimeline> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TripTimeLine()),
            );
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: Text(
          'ไทมไลน์สถานที่',
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSansThai(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('places')
              .where('placetripid', isEqualTo: widget.tripUid)
              .where('placerun', isEqualTo: "End")
              .where('placewhogo', arrayContains: uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Center(
                  child: Text('ไม่พบสถานที่'),
                );
              });
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
        ),
      ),
    );
  }

  void _showParticipantsDialog(List<dynamic> participants) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รายชื่อผู้เข้าร่วมสถานที่'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: participants.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(participants[index])
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('');
                    }
                    if (snapshot.hasError) {
                      return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text('ไม่พบข้อมูลผู้ใช้');
                    }
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    String firstName = userData['firstName'] ?? '';
                    String nickname = userData['nickname'] ?? '';
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 30.0,
                        backgroundImage:
                            NetworkImage(userData['profileImageUrl'] ?? ''),
                      ),
                      title: Text(firstName),
                      subtitle: Text(nickname),
                    );
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Widget buildPlaceItem(
      BuildContext context, Map<String, dynamic> placeData, place) {
    String placeName = placeData['placename'];
    int maxCharsFirstLine = 40;
    int maxCharsTotal = 40;

    int countTrip = placeData['placewhogo'].length;

    String displayedName = placeName.length > maxCharsFirstLine
        ? (placeName.length > maxCharsTotal
            ? placeName.substring(0, maxCharsFirstLine) + '...'
            : placeName.substring(0, maxCharsFirstLine) +
                '...' +
                (placeName.length > maxCharsTotal
                    ? placeName.substring(maxCharsFirstLine, maxCharsTotal) +
                        '...'
                    : placeName.substring(maxCharsFirstLine)))
        : placeName;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceTimelineDetail(
                tripUid: widget.tripUid ?? '',
                placeId: place.id,
                userUid: uid,
              ),
            ),
          );
        },
        child: Container(
          height: 150.0,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Color.fromARGB(255, 255, 255, 255)),
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    placeData['placepicUrl'] ??
                        'assets/userplan/userplan_image1.png',
                    height: 150.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 3),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
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
                                  fontSize: 15,
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
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              'จำนวนผู้เข้าร่วม : $countTrip คน',
                              style: GoogleFonts.ibmPlexSansThai(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              margin: EdgeInsets.all(0),
                              child: InkWell(
                                onTap: () {
                                  _showParticipantsDialog(
                                      placeData['placewhogo']);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Icon(
                                    Icons.person,
                                    size: 17,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
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
    home: Placetimeline(),
  ));
}
