import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:triptourapp/notificationcheck/notificationfunction.dart';

void main() {
  runApp(
    MaterialApp(
      home: SlideTime(),
    ),
  );
}

class SlideTime extends StatefulWidget {
  final String? selectedPlaceUid;

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
  DateTime nowtime = DateTime.now();
  Timestamp? placetimestart;
  Timestamp? placetimeend;
  DateTime? startTime;
  DateTime? endTime;
  DateTime timestart = DateTime.now();
  DateTime timeend = DateTime.now();
  DateTime? selectdate;
  String? formattedTime;
  String? formattedTimeEnd;
  List<DateTime> tripDates = [];
  List<DateTime> tripDatesNew = [];

  @override
  void didUpdateWidget(covariant SlideTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlaceUid != oldWidget.selectedPlaceUid) {
      setState(() {
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
          return Text('');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('');
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
              return Text('');
            }
            if (!tripSnapshot.hasData || !tripSnapshot.data!.exists) {
              return Text('');
            }

            final tripData = tripSnapshot.data!;
            DateTime tripStartDate = tripData['tripStartDate'].toDate();
            DateTime tripEndDate = tripData['tripEndDate'].toDate();
            timestart = tripData['tripStartDate'].toDate();
            timeend = tripData['tripEndDate'].toDate();
            placetimestart = placeData['placetimestart'];
            placetimeend = placeData['placetimeend'];
            tripStartDateFormatted =
                DateFormat('yyyy-MM-dd').format(tripStartDate);

            tripDates = [];
            for (DateTime date = DateTime(
                    tripStartDate.year, tripStartDate.month, tripStartDate.day);
                date.isBefore(DateTime(tripEndDate.year, tripEndDate.month,
                        tripEndDate.day)) ||
                    date.isAtSameMomentAs(DateTime(
                        tripEndDate.year, tripEndDate.month, tripEndDate.day));
                date = date.add(Duration(days: 1))) {
              tripDates.add(date);
            }

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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    endTime != null
                        ? 'เวลาสิ้นสุด: ${DateFormat('HH:mm').format(endTime!)}'
                        : 'โปรดเลือกเวลาสิ้นสุด',
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
                ],
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (startTime != null && endTime != null) {
                    if (startTime!.isBefore(timestart) ||
                        endTime!.isAfter(timeend)) {
                      _showTimeLimit(context);
                    } else {
                      _saveTime();
                    }
                  } else if (startTime == null || endTime == null) {
                    _showTimeAlert(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 245, 136, 2),
                ),
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 254, 0, 0),
                ),
                child: Text('รีเซ็ตเวลา'),
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
          .collection('places')
          .doc(widget.selectedPlaceUid)
          .update({
        'placetimestart': startTime,
        'placetimeend': endTime,
        'placeadd': 'Yes'
      });

      print('Start time saved successfully!');
    } catch (error) {
      print('Error saving start time: $error');
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
      final placeData = await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.selectedPlaceUid)
          .get();
      final placetripid = placeData['placetripid'];
      final tripData = await FirebaseFirestore.instance
          .collection('trips')
          .doc(placetripid)
          .get();

      tripData['tripStartDate'].toDate();
      DateTime tripEndDate = tripData['tripEndDate'].toDate();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('places')
          .where('placetripid', isEqualTo: placetripid)
          .get();

      bool isOverlapping = false;

      for (final doc in querySnapshot.docs) {
        final existingPlaceData = doc.data();
        final existingStartTime = existingPlaceData['placetimestart'];
        final existingEndTime = existingPlaceData['placetimeend'];

        if (existingStartTime != null && existingEndTime != null) {
          if ((startTime!.isAfter(existingStartTime.toDate()) &&
                  startTime!.isBefore(existingEndTime.toDate())) ||
              (endTime!.isAfter(existingStartTime.toDate()) &&
                  endTime!.isBefore(existingEndTime.toDate()))) {
            isOverlapping = true;
            _showInvalidTimeRangeAlert(context);
            break;
          }
        }
      }

      if (!isOverlapping && endTime!.isBefore(tripEndDate)) {
        Timestamp endTimestamp = Timestamp.fromDate(endTime!);
        Timestamp startTimestamp = Timestamp.fromDate(startTime!);
        _saveStarAndEndtTimeToFirestore(startTimestamp, endTimestamp);
        _Saved(context);
        await tripUpdatePlanNotification(tripData.id);
      } else {
        if (isOverlapping) {
          print('Invalid time: Overlapping with existing time');
        }
        if (endTime!.isAfter(tripEndDate)) {
          _showTimeMore(context);
        }
      }
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

  void _showTimeMore(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text('ระยะเวลาทริปเกินวันสิ้นสุดทริป'),
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

  void _showTimeLimit(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เเจ้งเตือน'),
          content: Text(
              'โปรดเลือกวันเวลาให้อยู่ในขอบเขตของวันเริ่มต้นทริปเเละสิ้นสุด'),
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
