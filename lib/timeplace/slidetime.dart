import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(
    MaterialApp(
      home: SlideTime(), // นำ MyApp() ไปเป็นหน้าจอหลัก
    ),
  );
}

class SlideTime extends StatefulWidget {
  final String? selectedPlaceUid; // รับค่า UID จาก SlidePlace widget

  const SlideTime({Key? key, this.selectedPlaceUid}) : super(key: key);

  @override
  _SlideTimeState createState() => _SlideTimeState();
}

class _SlideTimeState extends State<SlideTime> {
  List<String> availableDays = ['24', '25', '26'];
  String? selectedDay;
  String? tripStartDate = 'ไม่พบข้อมูล';
  String? tripEndDate = 'ไม่พบข้อมูล';
  String? tripStartDateFormatted;
  String? tripEndDateFormatted;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .doc(widget.selectedPlaceUid)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('ไม่พบข้อมูล');
        }
        final placeData = snapshot.data!;
        final placetripid = placeData['placetripid'];
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .doc(placetripid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> tripSnapshot) {
            if (tripSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (!tripSnapshot.hasData || !tripSnapshot.data!.exists) {
              return Text('ไม่พบข้อมูล');
            }
            final tripData = tripSnapshot.data!;
            DateTime tripStartDate = tripData['tripStartDate'].toDate();
            DateTime tripEndDate = tripData['tripEndDate'].toDate();
            tripStartDateFormatted =
                DateFormat('yyyy-MM-dd').format(tripStartDate);
            tripEndDateFormatted = DateFormat('yyyy-MM-dd').format(tripEndDate);
            return buildSlideTime();
          },
        );
      },
    );
  }

  Widget buildSlideTime() {
    List<int> daysInRange = [];
    if (tripStartDateFormatted != null && tripEndDateFormatted != null) {
      DateTime startDate = DateTime.parse(tripStartDateFormatted!);
      DateTime endDate = DateTime.parse(tripEndDateFormatted!);

      // หาวันที่ระหว่าง startdate และ enddate
      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
        DateTime day = startDate.add(Duration(days: i));
        daysInRange.add(day.day);
      }
    }

    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(0.0),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เลือกเวลาเริ่มต้น-สิ้นสุด',
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<int>(
                hint: Text('วันที่'),
                value: int.tryParse(selectedDay ?? ''),
                items: daysInRange.map((int day) {
                  return DropdownMenuItem<int>(
                    value: day,
                    child: Text(day.toString()),
                  );
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    selectedDay = value.toString();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
