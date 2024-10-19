import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/TripTimeLine.dart';
import 'package:triptourapp/addplace.dart';
import 'package:triptourapp/groupchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/main.dart';
import 'package:triptourapp/notificationcheck/notificationfunction.dart';
import '../timeplace.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HeadButton extends StatefulWidget {
  @override
  _HeadButtonState createState() => _HeadButtonState();
  final String? tripUid;
  const HeadButton({Key? key, this.tripUid}) : super(key: key);
}

final String tripUidsend = 'Uid';
void cancelTrip(BuildContext context, String tripUid) async {
  try {
    Fluttertoast.showToast(msg: 'กำลังลบทริป...');
    DocumentSnapshot tripSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

    if (!tripSnapshot.exists) {
      print('Trip not found');
      return;
    }

    // List<dynamic> tripJoin = tripSnapshot['tripJoin'];

    // if (tripJoin.length > 1) {
    //   await Fluttertoast.showToast(
    //       msg: 'จำนวนผู้ร่วมต้องไม่เกิน 1 คนจึงจะสามารถลบทริปได้');
    //   return;
    // }
    QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection('placemeet')
        .where('placetripid', isEqualTo: tripUid)
        .get();

    querySnapshot2.docs.forEach((document) async {
      String placePicUrl = document['placepicUrl'];

      Reference ref = FirebaseStorage.instance.refFromURL(placePicUrl);
      await ref.delete();

      await FirebaseFirestore.instance
          .collection('placemeet')
          .doc(document.id)
          .delete();
    });

    QuerySnapshot querySnapshot3 = await FirebaseFirestore.instance
        .collection('interest')
        .where('placetripid', isEqualTo: tripUid)
        .get();

    querySnapshot3.docs.forEach((document) async {
      String placePicUrl = document['placepicUrl'];

      Reference ref = FirebaseStorage.instance.refFromURL(placePicUrl);
      await ref.delete();

      await FirebaseFirestore.instance
          .collection('interest')
          .doc(document.id)
          .delete();
    });
    QuerySnapshot querySnapshot4 = await FirebaseFirestore.instance
        .collection('groupmessages')
        .where('tripChatUid', isEqualTo: tripUid)
        .get();

    querySnapshot4.docs.forEach((document) async {
      await FirebaseFirestore.instance
          .collection('groupmessages')
          .doc(document.id)
          .delete();
    });
    QuerySnapshot querySnapshot5 = await FirebaseFirestore.instance
        .collection('triprequest')
        .where('tripUid', isEqualTo: tripUid)
        .get();

    querySnapshot5.docs.forEach((document) async {
      await FirebaseFirestore.instance
          .collection('triprequest')
          .doc(document.id)
          .delete();
    });
    QuerySnapshot querySnapshot6 = await FirebaseFirestore.instance
        .collection('timeline')
        .where('placetripid', isEqualTo: tripUid)
        .get();

    querySnapshot6.docs.forEach((document) async {
      await FirebaseFirestore.instance
          .collection('timeline')
          .doc(document.id)
          .delete();
    });

    QuerySnapshot querySnapshot7 = await FirebaseFirestore.instance
        .collection('timeline')
        .where('placetripid', isEqualTo: tripUid)
        .get();

    querySnapshot7.docs.forEach((document) async {
      await FirebaseFirestore.instance
          .collection('timeline')
          .doc(document.id)
          .delete();
    });

    QuerySnapshot querySnapshot8 = await FirebaseFirestore.instance
        .collection('timelinestamp')
        .where('placetripid', isEqualTo: tripUid)
        .where('useruid', isEqualTo: uid)
        .get();
    querySnapshot8.docs.forEach((document) async {
      await FirebaseFirestore.instance
          .collection('timelinestamp')
          .doc(document.id)
          .delete();
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('places')
        .where('placetripid', isEqualTo: tripUid)
        .get();

    querySnapshot.docs.forEach((document) async {
      String placePicUrl = document['placepicUrl'];

      Reference ref = FirebaseStorage.instance.refFromURL(placePicUrl);
      await ref.delete();

      await FirebaseFirestore.instance
          .collection('places')
          .doc(document.id)
          .delete();
    });

    String tripProfileUrl = tripSnapshot['tripProfileUrl'];
    Reference ref = FirebaseStorage.instance.refFromURL(tripProfileUrl);
    await ref.delete();

    await FirebaseFirestore.instance.collection('trips').doc(tripUid).delete();

    Fluttertoast.showToast(msg: 'ลบทริปสำเร็จ');
    print('Trip canceled successfully');
  } catch (e) {
    print('Error canceling trip: $e');
  }
}

void checkAndUpdatePlaces(String tripUid) async {
  var placesSnapshot = await FirebaseFirestore.instance
      .collection('places')
      .where('placetripid', isEqualTo: tripUid)
      .where('placeadd', isEqualTo: 'Yes')
      .get();

  placesSnapshot.docs.forEach((place) async {
    var placeData = place.data();
    bool isPlaceEnd =
        DateTime.now().isAfter(placeData['placetimeend'].toDate());
    bool isPlaceLength =
        DateTime.now().isAfter(placeData['placetimestart'].toDate()) &&
            DateTime.now().isBefore(placeData['placetimeend'].toDate());

    if (isPlaceLength) {
      if (placeData['placerun'] != 'Running') {
        place.reference.update({'placerun': 'Running'});
        await placeRunNotification(tripUid, place.id);
      }
    }
    if (isPlaceEnd) {
      if (placeData['placerun'] != 'End') {
        place.reference.update({'placerun': 'End'});
        await placeEndNotification(tripUid, place.id);
      }
    }
  });
}

void showCancelTripDialog(BuildContext context, String tripUid) {
  TextEditingController remarkController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text('ยกเลิกทริป')),
        content: TextField(
          controller: remarkController,
          decoration: InputDecoration(
            hintText: 'กรุณากรอกหมายเหตุ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
          maxLines: 3,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveTripRemark(tripUid, remarkController.text);
              cancelTrip(context, tripUid);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ),
              );
              cancelTripNotification(tripUid);
            },
            child: Text('บันทึก'),
          ),
        ],
      );
    },
  );
}

Future<void> _saveTripRemark(String tripUid, String remark) async {
  try {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripUid)
        .update({'tripRemark': remark});
    print('หมายเหตุถูกบันทึกเรียบร้อย');
  } catch (e) {
    print('เกิดข้อผิดพลาดในการบันทึกหมายเหตุ: $e');
  }
}

String? uid = FirebaseAuth.instance.currentUser?.uid;

class _HeadButtonState extends State<HeadButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Container();
        }

        var tripData = snapshot.data?.data() as Map<String, dynamic>?;
        try {
          DateTime now = DateTime.now();
          if (tripData != null) {
            DateTime tripStartDate = tripData['tripStartDate'].toDate();
            DateTime tripEndDate = tripData['tripEndDate'].toDate();
            if (now.isAfter(tripStartDate) && now.isBefore(tripEndDate)) {
              if (tripData['tripStatus'] != 'กำลังดำเนินการ') {
                FirebaseFirestore.instance
                    .collection('trips')
                    .doc(widget.tripUid)
                    .update({'tripStatus': 'กำลังดำเนินการ'}).then((_) async {
                  await tripRunNotification(widget.tripUid ?? '');
                }).catchError((error) {
                  print('Failed to update placerun to Running: $error');
                });
                print('Trip status updated successfully');
              }
            } else if (now.isAfter(tripEndDate)) {
              if (tripData['tripStatus'] != 'สิ้นสุด') {
                FirebaseFirestore.instance
                    .collection('trips')
                    .doc(widget.tripUid)
                    .update({'tripStatus': 'สิ้นสุด'}).then((_) async {
                  await tripEndNotification(widget.tripUid ?? '');
                }).catchError((error) {
                  print('Failed to update placerun to Running: $error');
                });

                print('Trip status updated successfully');
              }
            } else {
              print('Trip has not started yet');
            }
          }
        } catch (e) {
          print('Error updating trip status: $e');
        }

        if (tripData != null) {
          var tripStatus = tripData['tripStatus'];

          if (tripStatus == 'กำลังดำเนินการ') {
            return Container(
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      children: [
                        Text(
                          'แผนการเดินทาง',
                          style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 0.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.grey,
                              size: 28,
                            ),
                            onPressed: () {
                              print(tripData['tripStatus']);

                              checkAndUpdatePlaces(widget.tripUid ?? '');
                              setState(() {});
                            },
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            showCancelTripDialog(
                                context, widget.tripUid.toString());
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            'ยกเลิกทริป',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupScreenPage(
                                    tripUid: widget.tripUid ?? ''),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat),
                              SizedBox(width: 8),
                              Text(
                                'แชทกลุ่ม',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddPage(tripUid: widget.tripUid ?? '')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on),
                              SizedBox(width: 2),
                              Text(
                                'เพิ่มสถานที่',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TimePlacePage(tripUid: widget.tripUid)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time),
                              SizedBox(width: 2),
                              Text(
                                'กำหนดเวลาสถานที่',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (tripStatus == 'ยังไม่เริ่มต้น') {
            return Container(
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      children: [
                        Text(
                          'แผนการเดินทาง',
                          style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 0.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.grey,
                              size: 28,
                            ),
                            onPressed: () {
                              checkAndUpdatePlaces(widget.tripUid ?? '');
                              setState(() {});
                            },
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            showCancelTripDialog(
                                context, widget.tripUid.toString());
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            'ยกเลิกทริป',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupScreenPage(
                                    tripUid: widget.tripUid ?? ''),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat),
                              SizedBox(width: 8),
                              Text(
                                'แชทกลุ่ม',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddPage(tripUid: widget.tripUid ?? '')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on),
                              SizedBox(width: 2),
                              Text(
                                'เพิ่มสถานที่',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TimePlacePage(tripUid: widget.tripUid)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time),
                              SizedBox(width: 2),
                              Text(
                                'กำหนดเวลาสถานที่',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                ],
              ),
            );
          } else if (tripStatus == 'สิ้นสุด') {
            return Container(
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TripTimeLine()),
                            );
                            Fluttertoast.showToast(msg: 'ทริปสิ้นสุดเเล้ว');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            fixedSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'สิ้นสุดทริป',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: HeadButton(),
    ),
  );
}
