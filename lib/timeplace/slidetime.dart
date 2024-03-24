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
  Timestamp? placetimestart;
  Timestamp? placetimeend;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? formattedTime;
  String? formattedTimeEnd; // ย้ายตัวแปร formattedTime มาที่นี่

  TimeOfDay? _convertToTimeOfDay(String? timeString) {
    if (timeString != null && timeString.isNotEmpty) {
      final List<String> parts = timeString.split(':');
      if (parts.length == 2) {
        final int hour = int.tryParse(parts[0]) ?? 0;
        final int minute = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

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
            placetimestart = placeData['placetimestart'];
            placetimeend = placeData['placetimeend'];
            tripStartDateFormatted =
                DateFormat('yyyy-MM-dd').format(tripStartDate);

            tripEndDateFormatted = DateFormat('yyyy-MM-dd').format(tripEndDate);

            if (placetimestart == null) {
              formattedTime = '00:00';
            } else if (placetimestart != null) {
              DateTime placetimestartnew = placetimestart!.toDate();

              formattedTime = DateFormat('HH:mm').format(placetimestartnew);
            }
            if (placetimeend == null) {
              formattedTimeEnd = '00:00';
            } else if (placetimeend != null) {
              DateTime placetimeendnew = placetimeend!.toDate();

              formattedTimeEnd = DateFormat('HH:mm').format(placetimeendnew);
            }
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
        daysInRange.add(day.day); // เพิ่มวันที่ลงในรายการวันที่
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
              DropdownButton<DateTime>(
                hint: Text('วันที่'),
                value: selectedDay != null
                    ? DateFormat('yyyy-MM-dd').parse(selectedDay!)
                    : null,
                items: daysInRange.map((day) {
                  DateTime currentDate = DateTime.parse(tripStartDateFormatted!)
                      .add(Duration(days: day - 1));
                  return DropdownMenuItem<DateTime>(
                    value: currentDate,
                    child: Text(DateFormat('yyyy-MM-dd').format(currentDate)),
                  );
                }).toList(),
                onChanged: (DateTime? value) {
                  setState(() {
                    if (value != null) {
                      selectedDay = DateFormat('yyyy-MM-dd').format(value);
                      print(selectedDay);
                    }
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เวลาเริ่มต้น: ${formattedTime ?? ''}', // แสดงเวลาเริ่มต้นที่ถูกเลือก (ถ้ามี)
                    style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectStartTime(context);
                    },
                    child: Text('เลือกเวลาเริ่มต้น'),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เวลาสิ้นสุด: ${formattedTimeEnd ?? ''}', // แสดงเวลาเริ่มต้นที่ถูกเลือก (ถ้ามี)
                    style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectEndTime(context);
                    },
                    child: Text('เลือกเวลาเริ่มต้น'),
                  ),
                ],
              ),
            ],
          ), // เพิ่มระยะห่างระหว่าง DropdownButton และเวลาเริ่มต้น
        ],
      ),
    );
  }

  void _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedStartTime != null && selectedDay != null) {
      // แปลง TimeOfDay เป็น DateTime
      DateTime selectedDateTime = DateTime.parse(selectedDay!);
      selectedDateTime = selectedDateTime.add(Duration(
          hours: pickedStartTime.hour, minutes: pickedStartTime.minute));

      // แปลง DateTime เป็น Timestamp
      Timestamp timestamp = Timestamp.fromDate(selectedDateTime);

      setState(() {
        placetimestart = timestamp;
        print(placetimestart); // กำหนด placetimestart เป็น Timestamp
      });
      _saveStartTimeToFirestore(placetimestart!);
    } else {
      _AlertSelectDate(context);
    }
  }

  void _saveStartTimeToFirestore(Timestamp startTime) async {
    try {
      await FirebaseFirestore.instance
          .collection('places') // ใช้คอลเล็กชัน "places"
          .doc(widget
              .selectedPlaceUid) // เอกสารที่มี UID เท่ากับ widget.selectedPlaceUid
          .update({
        'placetimestart': startTime, // ส่ง Timestamp ไปยัง Firestore
      });
      print('Start time saved successfully!');
    } catch (error) {
      print('Error saving start time: $error');
    }
  }

  void _saveEndTimeToFirestore(Timestamp endTime) async {
    try {
      await FirebaseFirestore.instance
          .collection('places') // ใช้คอลเล็กชัน "places"
          .doc(widget
              .selectedPlaceUid) // เอกสารที่มี UID เท่ากับ widget.selectedPlaceUid
          .update({
        'placetimeend': endTime, // ส่ง Timestamp ไปยัง Firestore
      });
      print('Start time saved successfully!');
    } catch (error) {
      print('Error saving start time: $error');
    }
  }

  void _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedEndTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedEndTime != null && selectedDay != null) {
      // แปลง TimeOfDay เป็น DateTime
      DateTime selectedDateTime = DateTime.parse(selectedDay!);
      selectedDateTime = selectedDateTime.add(
          Duration(hours: pickedEndTime.hour, minutes: pickedEndTime.minute));

      // แปลง DateTime เป็น Timestamp
      Timestamp timestamp = Timestamp.fromDate(selectedDateTime);

      setState(() {
        placetimeend = timestamp;
        print(placetimeend); // กำหนด placetimestart เป็น Timestamp
      });
      _saveEndTimeToFirestore(placetimeend!);
    } else {
      _AlertSelectDate(context);
    }
  }

  void _showInvalidTimeAlertStart(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('โปรดเลือกเวลามากกว่าเวลาสิ้นสุด'),
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

  void _showInvalidTimeAlertEnd(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('โปรดเลือกเวลามากกว่าเวลาเริ่มต้น'),
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

  void _AlertSelectDate(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('โปรดเลือกวันที่'),
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
}
