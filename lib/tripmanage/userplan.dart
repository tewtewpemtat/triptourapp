import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:triptourapp/tripmanage/maproute.dart';
import '../infoplace.dart';

class UserPlan extends StatefulWidget {
  @override
  final String? tripUid;
  const UserPlan({Key? key, this.tripUid}) : super(key: key);
  _UserPlanState createState() => _UserPlanState();
}

class _UserPlanState extends State<UserPlan> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isPlaceLength = false;
  bool isPlaceEnd = false;
  bool isPlaceStart = false;
  double userLatitude = 0.0; // พิกัดละติจูดปัจจุบันของผู้ใช้
  double userLongitude = 0.0; // พิกัดลองจิจูดปัจจุบันของผู้ใช้

  @override
  void initState() {
    super.initState();

    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return // Set a fixed height or use constraints
        StreamBuilder<QuerySnapshot>(
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
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Center(
              child: Text('ยังไม่มีการกำหนดสถานที่'),
            );
          });
        }
        final places = snapshot.data!.docs;
        if (places != null) {
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
        } else {
          return Container();
        }
      },
    );
  }

  void joinorleave(DocumentSnapshot place, bool join, context) async {
    // ดึงข้อมูลปัจจุบันของฟิลด์ placewhogo
    List<dynamic> currentWhogo = List.from(place['placewhogo'] ?? []);

    // เพิ่มหรือลบ uid ตามที่ต้องการ
    if (join == false) {
      if (!currentWhogo.contains(uid)) {
        currentWhogo.add(uid);
      }
    } else {
      currentWhogo.remove(uid);
    }

    // อัปเดตฟิลด์ placewhogo ใน Firestore
    try {
      await FirebaseFirestore.instance
          .collection('places')
          .doc(place.id)
          .update({
        'placewhogo': currentWhogo,
      });
    } catch (error) {
      // Error handling
      print("Failed to update placewhogo: $error");
      Fluttertoast.showToast(
        msg: "Failed to update placewhogo: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void rounttomap(DocumentSnapshot place, GeoPoint placestart,
      List<dynamic> placewhogo, context) async {
    double placelatitude = placestart.latitude;
    double placelongitude = placestart.longitude;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          placeLatitude: placelatitude, // ประกาศพารามิเตอร์ placelatitude
          placeLongitude: placelongitude, // ประกาศพารามิเตอร์ placelongitude
        ),
      ),
    );

    if (placewhogo.contains(uid)) {
      print('uid นี้อยู่ในรายการ placewhogo');
    } else {
      print('uid นี้ไม่อยู่ในรายการ placewhogo');
    }
  }

  void _showTripEnd(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('ทริปของสถานที่นี้ได้สิ้นสุดไปเเล้ว'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTripNotStart(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('ทริปของสถานที่นี้ยังไม่เริ่มต้น'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTripJoin(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('คุณไม่ได้เลือกเข้าร่วมสถานที่นี้'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    } catch (e) {
      print("Error getting user location: $e");
    }
  }

  Widget buildPlaceItem(
      BuildContext context, Map<String, dynamic> placeData, place) {
    String placeName = placeData['placename'];
    String placeAddress = placeData['placeaddress'];
    int maxCharsFirstLine = 40; // Maximum characters for the first line
    int maxCharsTotal = 40; // Maximum characters to display in total
    int maxCharsFirstLine2 = 50; // Maximum characters for the first line
    int maxCharsTotal2 = 60; // Maximum characters to display in total
    Timestamp placeStartTimeStamp = placeData['placetimestart'];
    DateTime placeStartTime = placeStartTimeStamp.toDate();
    Timestamp placeEndTimeStamp = placeData[
        'placetimestart']; // เพิ่มการเข้าถึง placetimestart จาก placeData
    DateTime placeEndTime =
        placeEndTimeStamp.toDate(); // แปลง Timestamp เป็น DateTime
    int countTrip = placeData['placewhogo'].length;
    // เงื่อนไขเพิ่มเติมเพื่อตรวจสอบว่า placetimestart มีค่ามากกว่าหรือเท่ากับวันเวลาปัจจุบันหรือไม่
    bool isPlaceTimeValid =
        placeData['placetimeend'].toDate().isAfter(DateTime.now());
    isPlaceEnd = DateTime.now().isAfter(placeData['placetimestart'].toDate()) &&
        DateTime.now().isAfter(placeData['placetimeend'].toDate());
    isPlaceStart =
        DateTime.now().isBefore(placeData['placetimestart'].toDate());
    isPlaceLength =
        DateTime.now().isAfter(placeData['placetimestart'].toDate()) &&
            DateTime.now().isBefore(placeData['placetimeend'].toDate());
    if (isPlaceLength) {
      place.reference.update({'placerun': 'Running'});
    }
    if (isPlaceEnd) {
      place.reference.update({'placerun': 'End'});
    }
    bool isUserGoing;
    isUserGoing = (placeData['placewhogo'] as List).contains(uid);
    String displayedName = placeName.length > maxCharsFirstLine
        ? (placeName.length > maxCharsTotal
            ? placeName.substring(0, maxCharsFirstLine) +
                '...' // Add ... after truncating the first line
            : placeName.substring(0, maxCharsFirstLine) +
                '...' +
                (placeName.length > maxCharsTotal
                    ? placeName.substring(maxCharsFirstLine, maxCharsTotal) +
                        '...'
                    : placeName.substring(maxCharsFirstLine)))
        : placeName;
    String displayedName2 = placeAddress.length > maxCharsFirstLine2
        ? (placeAddress.length > maxCharsTotal2
            ? placeAddress.substring(0, maxCharsFirstLine2) +
                '...' // Add ... after truncating the first line
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
      child: InkWell(
        onTap: () {
          if (placeData['placerun'] == 'Running') {
            if (placeData['placewhogo'].contains(uid)) {
              print(place.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoPlacePage(
                      tripUid: widget.tripUid!, placeid: place.id),
                ),
              );
            } else {
              _showTripJoin(context);
            }
          } else if (placeData['placerun'] == 'Start') {
            _showTripNotStart(context);
          } else {
            _showTripEnd(context);
          }
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // Border color
                width: 1.0, // Border width
              ),
              borderRadius: BorderRadius.circular(10),
              color: !isPlaceLength & !isPlaceStart
                  ? Color.fromARGB(53, 106, 105, 105)
                  : Color.fromARGB(255, 255, 255, 255)),
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
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 13),
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
                                displayedName ?? '',
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
                              color: Colors.black, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                            color: Color(0xFF1E30D7), // Background color
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
                                        (placeData['placetimestart']
                                                as Timestamp)
                                            .toDate()) ??
                                    '',
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
                                            .toDate()) ??
                                    '',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'จำนวนผู้เข้าร่วม : $countTrip',
                              style: GoogleFonts.ibmPlexSansThai(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                                width: 5), // Add spacing between text and image
                            GestureDetector(
                              onTap: () {
                                {
                                  if (placeData['placestart'] != '') {
                                    rounttomap(place, placeData['placestart'],
                                        placeData['placewhogo'], context);
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "ยังไม่มีการกำหนดจุดนัดพบ",
                                    );
                                  }
                                }
                                ;
                              },
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/gps.png', // Image asset path
                                    width: 25, // Image width
                                    height: 25, // Image height
                                  ),
                                  Text(
                                    'จุดนัดพบ',
                                    style: GoogleFonts.ibmPlexSansThai(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width: 4), // Add spacing between image and text
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: isPlaceTimeValid
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            joinorleave(
                                                place, isUserGoing, context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Color.fromARGB(
                                                255, 167, 166, 166),
                                            onPrimary: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fixedSize: Size(70, 10),
                                          ),
                                          child: !isUserGoing
                                              ? Text(
                                                  'เข้าร่วม',
                                                  style: GoogleFonts
                                                      .ibmPlexSansThai(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255),
                                                  ),
                                                )
                                              : Text(
                                                  'ยกเลิกการเข้าร่วม',
                                                  style: GoogleFonts
                                                      .ibmPlexSansThai(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255),
                                                  ),
                                                )),
                                    )
                                  : Container(
                                      width: 70,
                                      height: 40,
                                      child: TextButton(
                                        onPressed: null,
                                        child: Text(
                                          'สิ้นสุด',
                                          style: GoogleFonts.ibmPlexSansThai(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 49, 49, 49),
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                        ),
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
        ),
      ),
    );
  }
}
