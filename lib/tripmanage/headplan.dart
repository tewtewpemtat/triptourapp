import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:triptourapp/maplocation.dart';
import 'package:triptourapp/notificationcheck/notificationfunction.dart';
import 'package:triptourapp/tripmanage/maproute.dart';
import 'mapselect.dart';
import 'package:geolocator/geolocator.dart';
import '../infoplace.dart';

class HeadPlan extends StatefulWidget {
  final String? tripUid;
  const HeadPlan({Key? key, this.tripUid}) : super(key: key);
  _HeadPlanPageState createState() => _HeadPlanPageState();
}

class _HeadPlanPageState extends State<HeadPlan> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isPlaceLength = false;
  bool isPlaceEnd = false;
  bool isPlaceStart = false;
  double? placelat;
  double? placelong;
  LatLng? selectedPosition = null;
  LatLng? markedPosition;
  double userLatitude = 0.0;
  double userLongitude = 0.0;

  @override
  void initState() {
    super.initState();

    getUserLocation();
  }

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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Center(
              child: Text('ยังไม่มีการกำหนดสถานที่'),
            );
          });
        }
        final places = snapshot.data!.docs;
        places.sort((a, b) {
          final aEndTime = a['placetimestart'] as Timestamp;
          final bEndTime = b['placetimestart'] as Timestamp;
          return aEndTime.compareTo(bEndTime);
        });

        return Column(
          children: places.map((place) {
            final placeData = place.data() as Map<String, dynamic>;

            bool isPlaceEnd =
                DateTime.now().isAfter(placeData['placetimestart'].toDate()) &&
                    DateTime.now().isAfter(placeData['placetimeend'].toDate());
            bool isPlaceLength =
                DateTime.now().isAfter(placeData['placetimestart'].toDate()) &&
                    DateTime.now().isBefore(placeData['placetimeend'].toDate());

            if (isPlaceLength) {
              if (placeData['placerun'] != 'Running') {
                place.reference.update({'placerun': 'Running'}).then((_) async {
                  await placeRunNotification(widget.tripUid ?? '', place.id);
                }).catchError((error) {
                  print('Failed to update placerun to Running: $error');
                });
              }
            }

            if (isPlaceEnd) {
              if (placeData['placerun'] != 'End') {
                place.reference.update({'placerun': 'End'}).then((_) async {
                  await placeEndNotification(widget.tripUid ?? '', place.id);
                }).catchError((error) {
                  print('Failed to update placerun to End: $error');
                });
              }
            }

            return buildPlaceItem(context, placeData, place);
          }).toList(),
        );
      },
    );
  }

  void _openMapSelectionPage(DocumentSnapshot place, double placelat,
      double placelong, context) async {
    print(placelat);
    selectedPosition = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(
            tripUid: widget.tripUid, placelat: placelat, placelong: placelong),
      ),
    );
    if (selectedPosition != null) {
      FirebaseFirestore.instance
          .collection('places')
          .doc(place.id)
          .update({
            'placestart': GeoPoint(
                selectedPosition!.latitude, selectedPosition!.longitude)
          })
          .then((value) {})
          .catchError((error) {
            print("Failed to update placestart: $error");
            Fluttertoast.showToast(
                msg: "Failed to update placestart: $error",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          });
    }
  }

  void rounttomap(DocumentSnapshot place, GeoPoint placestart,
      List<dynamic> placewhogo, context) async {
    double placelatitude = placestart.latitude;
    double placelongitude = placestart.longitude;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          tripUid: widget.tripUid,
          placeid: place.id,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          placeLatitude: placelatitude,
          placeLongitude: placelongitude,
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

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          userLatitude = position.latitude;
          userLongitude = position.longitude;
        });
      }
    } catch (e) {
      print("Error getting user location: $e");
    }
  }

  void _showTimePickerDialog(Timestamp initialTime, String tripid,
      String placeid, BuildContext context) async {
    DateTime selectedDateTime = (initialTime.toDate()).add(Duration(
        hours: initialTime.toDate().hour,
        minutes: initialTime.toDate().minute));

    DocumentSnapshot tripSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripid).get();

    Timestamp tripEndDate = tripSnapshot['tripEndDate'];

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime.toDate()),
    );

    if (selectedTime != null) {
      selectedDateTime = DateTime(selectedDateTime.year, selectedDateTime.month,
          selectedDateTime.day, selectedTime.hour, selectedTime.minute);

      if (selectedDateTime.isBefore(tripEndDate.toDate())) {
        await FirebaseFirestore.instance
            .collection('places')
            .doc(placeid)
            .update({
          'placetimeend': selectedDateTime,
        });

        Fluttertoast.showToast(
          msg: "ขยายเวลาเสร็จสิ้น",
        );
      } else {
        await FirebaseFirestore.instance
            .collection('places')
            .doc(placeid)
            .update({
          'placetimeend': selectedDateTime,
        });
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(tripid)
            .update({
          'tripEndDate': selectedDateTime,
        });
        Fluttertoast.showToast(
          msg: "ขยายเวลาเสร็จสิ้น",
        );
      }
    }
  }

  Widget buildPlaceItem(
      BuildContext context, Map<String, dynamic> placeData, place) {
    String placeName = placeData['placename'];
    int maxCharsFirstLine = 40;
    int maxCharsTotal = 40;

    Timestamp placeStartTimeStamp = placeData['placetimestart'];
    Timestamp placeEndTimeStamp = placeData['placetimeend'];
    placeStartTimeStamp.toDate();
    placeEndTimeStamp.toDate();
    bool placestart;
    int countTrip = placeData['placewhogo'].length;
    if (placeData['placestart'] == '') {
      placestart = true;
    } else {
      placestart = false;
    }

    bool isPlaceTimeValid = placeData['placetimestart']
            .toDate()
            .isAfter(DateTime.now()) ||
        placeData['placetimestart'].toDate().isAtSameMomentAs(DateTime.now());

    isPlaceEnd = DateTime.now().isAfter(placeData['placetimestart'].toDate()) &&
        DateTime.now().isAfter(placeData['placetimeend'].toDate());
    isPlaceStart =
        DateTime.now().isBefore(placeData['placetimestart'].toDate());
    isPlaceLength =
        DateTime.now().isAfter(placeData['placetimestart'].toDate()) &&
            DateTime.now().isBefore(placeData['placetimeend'].toDate());

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
          if (placeData['placerun'] == 'Running') {
            print(place.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    InfoPlacePage(tripUid: widget.tripUid!, placeid: place.id),
              ),
            );
          } else if (placeData['placerun'] == 'Start') {
            _showTripNotStart(context);
          } else {
            _showTripEnd(context);
          }
        },
        child: Container(
          height: 200.0,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
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
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 3),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MapShowLocationPage(
                                          latitude: placeData['placeLatitude'],
                                          longitude:
                                              placeData['placeLongitude'])),
                                );
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/mark.png',
                                    width: 12,
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    'ตำแหน่ง',
                                    style: GoogleFonts.ibmPlexSansThai(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                        color: Color.fromARGB(252, 165, 3, 3),
                                        decorationColor:
                                            Color.fromARGB(255, 180, 2, 2)),
                                  ),
                                ],
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
                        Text(
                          'จำนวนผู้เข้าร่วม : $countTrip',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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
                                            _openMapSelectionPage(
                                                place,
                                                placeData['placeLatitude'] ??
                                                    13.736717,
                                                placeData['placeLongitude'] ??
                                                    100.523186,
                                                context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor:
                                                const Color.fromARGB(
                                                    255, 0, 0, 0),
                                            backgroundColor: Color.fromARGB(
                                                255, 167, 166, 166),
                                            fixedSize: Size(70, 10),
                                          ),
                                          child: placestart
                                              ? Text(
                                                  'กำหนดจุดนัดพบ',
                                                  style: GoogleFonts
                                                      .ibmPlexSansThai(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255),
                                                  ),
                                                )
                                              : Text(
                                                  'จุดนัดพบ',
                                                  style: GoogleFonts
                                                      .ibmPlexSansThai(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255),
                                                  ),
                                                )),
                                    )
                                  : placeData['placerun'] == 'Running'
                                      ? Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                child: TextButton(
                                                  onPressed: () {
                                                    if (placeData[
                                                                'placestart'] !=
                                                            '' &&
                                                        (placeData['placerun'] ==
                                                                'Running' ||
                                                            placeData[
                                                                    'placerun'] ==
                                                                'Start')) {
                                                      rounttomap(
                                                          place,
                                                          placeData[
                                                              'placestart'],
                                                          placeData[
                                                              'placewhogo'],
                                                          context);
                                                    } else if (placeData[
                                                            'placestart'] ==
                                                        '') {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "สถานที่นี้ไม่มีการกำหนดจุดนัดพบ",
                                                      );
                                                    } else {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "สถานที่นี้สิ้นสุดไปเเล้ว",
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    'จุดนัดพบ',
                                                    style: GoogleFonts
                                                        .ibmPlexSansThai(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 49, 49, 49),
                                                    ),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Container(
                                                child: TextButton(
                                                  onPressed: () {
                                                    _showTimePickerDialog(
                                                      placeData['placetimeend']
                                                          as Timestamp,
                                                      widget.tripUid ?? '',
                                                      place.id,
                                                      context,
                                                    );
                                                  },
                                                  child: Text(
                                                    'ขยายเวลา',
                                                    style: GoogleFonts
                                                        .ibmPlexSansThai(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 236, 234, 234),
                                                    ),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 5, 114, 239),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          width: 70,
                                          height: 40,
                                          child: TextButton(
                                            onPressed: () {
                                              if (placeData['placestart'] !=
                                                      '' &&
                                                  (placeData['placerun'] ==
                                                          'Running' ||
                                                      placeData['placerun'] ==
                                                          'Start')) {
                                                rounttomap(
                                                    place,
                                                    placeData['placestart'],
                                                    placeData['placewhogo'],
                                                    context);
                                              } else if (placeData[
                                                      'placestart'] ==
                                                  '') {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "สถานที่นี้ไม่มีการกำหนดจุดนัดพบ",
                                                );
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "สถานที่นี้สิ้นสุดไปเเล้ว",
                                                );
                                              }
                                            },
                                            child: Text(
                                              'จุดนัดพบ',
                                              style:
                                                  GoogleFonts.ibmPlexSansThai(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 49, 49, 49),
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

void main() {
  runApp(MaterialApp(
    home: HeadPlan(),
  ));
}
