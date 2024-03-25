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
  DateTime? startTime;
  DateTime? endTime;
  DateTime? selectdate;
  String? formattedTime;
  String? formattedTimeEnd; // ย้ายตัวแปร formattedTime มาที่นี่
  List<DateTime> tripDates = [];
  List<DateTime> tripDatesNew = [];

  @override
  void didUpdateWidget(covariant SlideTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlaceUid != oldWidget.selectedPlaceUid) {
      setState(() {
        // เมื่อ selectedPlaceUid เปลี่ยนค่า กำหนด startTime และ endTime เป็น null
        startTime = null;
        endTime = null;
        selectedDay = null;
        selectdate = null;
      });
    }
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

            tripDates = []; // ล้างรายการเดิมก่อนที่จะสร้างรายการใหม่
            for (DateTime date = tripStartDate;
                date.isBefore(tripEndDate) ||
                    date.isAtSameMomentAs(tripEndDate);
                date = date.add(Duration(days: 1))) {
              tripDates.add(date);
            }

            // อัปเดตค่าของตัวแปร tripDates หลังจากสร้างรายการเสร็จสมบูรณ์
            print(widget.selectedPlaceUid);
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
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(0.0),
      height: 200,
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
                items: tripDates.map((day) {
                  return DropdownMenuItem<DateTime>(
                    value: day,
                    child: Text(DateFormat('dd-MM-yyyy').format(day)),
                  );
                }).toList(),
                onChanged: (DateTime? value) {
                  setState(() {
                    if (value != null) {
                      selectedDay = DateFormat('yyyy-MM-dd').format(value);
                      selectdate = value;
                      print(selectdate);
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
                    startTime != null
                        ? 'เวลาเริ่มต้น: ${DateFormat('HH:mm').format(startTime!)}'
                        : 'โปรดเลิอกเวลาเริ่มต้น',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectStartTime(context, selectdate);
                    },
                    child: Text('เลือกเวลา'),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    endTime != null
                        ? 'เวลาสิ้นสุด: ${DateFormat('HH:mm').format(endTime!)}'
                        : 'โปรดเลือกเวลาเริ่มต้น',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectEndTime(context, selectdate);
                    },
                    child: Text('เลือกเวลา'),
                  ),
                  // เพิ่มระยะห่าง
                ],
              ),
            ],
          ), // เพิ่มระยะห่างระหว่าง DropdownButton และเวลาเริ่มต้น
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (startTime != null && endTime != null) {
                    _saveTime();
                  } else {
                    _showTimeAlert(context);
                  }
                },
                child: Text('บันทึกเวลา '),
              ),
              SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    startTime = null;
                    endTime = null;
                  });
                },
                child: Text('ล้างเวลา'),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _selectStartTime(BuildContext context, DateTime? selectedDay) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && selectedDay != null) {
      setState(() {
        startTime = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          picked.hour,
          picked.minute,
        );
      });
    } else if (selectedDay == null) {
      _AlertSelectDate(context);
    }
  }

  void _selectEndTime(BuildContext context, DateTime? selectedDay) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && selectedDay != null) {
      setState(() {
        endTime = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          picked.hour,
          picked.minute,
        );
        print(endTime);
      });
    } else if (selectedDay == null) {
      _AlertSelectDate(context);
    }
  }

  void _saveStarAndEndtTimeToFirestore(
    Timestamp startTime,
    Timestamp endTime,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('places') // ใช้คอลเล็กชัน "places"
          .doc(widget
              .selectedPlaceUid) // เอกสารที่มี UID เท่ากับ widget.selectedPlaceUid
          .update({
        'placetimestart': startTime,
        'placetimeend': endTime // ส่ง Timestamp ไปยัง Firestore
      });

      print('Start time saved successfully!');
    } catch (error) {
      print('Error saving start time: $error');
    }
  }

  void _clearEndTime(BuildContext context) {
    setState(() {
      placetimeend = null;
      print('Start time cleared!');
    });
    _clearEndTimeFromFirestore(); // ส่งค่า null เพื่อลบข้อมูลจาก Firestore
  }

  void _clearEndTimeFromFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.selectedPlaceUid)
          .update({
        'placetimeend': null,
      });
      print('Start time cleared successfully!');
    } catch (error) {
      print('Error clearing end time: $error');
    }
  }

  void _clearStartTime(BuildContext context) {
    setState(() {
      placetimestart = null;
      print('Start time cleared!');
    });
    _clearStartTimeFromFirestore(); // ส่งค่า null เพื่อลบข้อมูลจาก Firestore
  }

  void _clearStartTimeFromFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.selectedPlaceUid)
          .update({
        'placetimestart': null,
      });
      print('Start time cleared successfully!');
    } catch (error) {
      print('Error clearing start time: $error');
    }
  }

  void _showInvalidTimeAlertStart(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('โปรดเลือกเวลาเริ่มต้นที่น้อยกว่าเวลาสิ้นสุด'),
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
          content: Text('โปรดเลือกเวลาสิ้นสุดมากกว่าเวลาเริ่มต้น'),
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
          content: Text('โปรดเลือกวันที่ก่อนเลือกเวลา'),
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

  void _Saved(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('บันทึกวันเวลาเสร็จสิ้น'),
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

  void _saveTime() async {
    if (startTime!.isAfter(endTime!)) {
      _showInvalidTimeAlertStart(context);
    } else if (endTime!.isBefore(startTime!)) {
      _showInvalidTimeAlertEnd(context);
    } else {
      // Your Firebase Firestore code
      final placeData = await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.selectedPlaceUid)
          .get();

      final placetripid = placeData['placetripid'];

      final tripData = await FirebaseFirestore.instance
          .collection('trips')
          .doc(placetripid)
          .get();

      DateTime tripStartDate = tripData['tripStartDate'].toDate();
      DateTime tripEndDate = tripData['tripEndDate'].toDate();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('places')
          .where('placetripid', isEqualTo: placetripid)
          .get();

      for (final doc in querySnapshot.docs) {
        final existingPlaceData = doc.data();
        final existingStartTime = existingPlaceData['placetimestart'];
        final existingEndTime = existingPlaceData['placetimeend'];

        if (existingStartTime != null && existingEndTime != null) {
          if ((startTime!.isAfter(existingStartTime.toDate()) &&
                  startTime!.isBefore(existingEndTime.toDate())) ||
              (endTime!.isAfter(existingStartTime.toDate()) &&
                  endTime!.isBefore(existingEndTime.toDate()))) {
            print('Invalid time: Overlapping with existing time');
          } else {
            Timestamp endTimestamp = Timestamp.fromDate(endTime!);
            Timestamp startTimestamp = Timestamp.fromDate(startTime!);
            _saveStarAndEndtTimeToFirestore(startTimestamp, endTimestamp);
            print('Time is okay');
          }
        } else {
          Timestamp endTimestamp = Timestamp.fromDate(endTime!);
          Timestamp startTimestamp = Timestamp.fromDate(startTime!);
          _saveStarAndEndtTimeToFirestore(startTimestamp, endTimestamp);
        }
      }
      _Saved(context);
    }
  }

  Future<bool> _checkTimeRangeValidity(Timestamp newStartTime) async {
    try {
      // ดึงข้อมูลที่เกี่ยวข้องกับ placetripid
      final placeData = await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.selectedPlaceUid)
          .get();

      final placetripid = placeData['placetripid'];

      // ดึงข้อมูลที่เกี่ยวข้องกับ placetripid ใน trips collection
      final tripData = await FirebaseFirestore.instance
          .collection('trips')
          .doc(placetripid)
          .get();

      // แปลงวันเริ่มต้นและสิ้นสุดของทริปเป็น DateTime
      DateTime tripStartDate = tripData['tripStartDate'].toDate();
      DateTime tripEndDate = tripData['tripEndDate'].toDate();

      // ดึงข้อมูลที่เกี่ยวข้องกับสถานที่ที่มี placetripid เดียวกัน
      final querySnapshot = await FirebaseFirestore.instance
          .collection('places')
          .where('placetripid', isEqualTo: placetripid)
          .get();

      // ตรวจสอบว่า placetimestart ใหม่อยู่ในช่วงเวลาที่ไม่ซ้ำกันกับสถานที่อื่น ๆ
      for (final doc in querySnapshot.docs) {
        final existingPlaceData = doc.data();
        final existingStartTime = existingPlaceData['placetimestart'];
        final existingEndTime = existingPlaceData['placetimeend'];

        // ตรวจสอบช่วงเวลา
        if (existingStartTime != null && existingEndTime != null) {
          if (newStartTime.compareTo(existingStartTime) >= 0 &&
              newStartTime.compareTo(existingEndTime) <= 0) {
            // ช่วงเวลาไม่ถูกต้อง
            return false;
          }
        }
      }

      // หากไม่มีสถานที่ใดๆที่ชนกันในช่วงเวลาเดียวกัน
      return true;
    } catch (error) {
      print('Error checking time range validity: $error');
      return false;
    }
  }

  void _showInvalidTimeRangeAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('โปรดเลือกวันเวลาที่ไม่อยู่ในช่วงของสถานที่อื่น ๆ'),
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

  void _showTimeAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('โปรดเลือกวันเวลาให้ครบถ้วน'),
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
