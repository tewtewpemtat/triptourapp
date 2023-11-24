import 'package:flutter/material.dart';
import 'package:triptourapp/timeplace/slideplace.dart';
import 'package:triptourapp/timeplace/slidetime.dart';
import 'package:triptourapp/timeplace/placesum.dart';

class TimePlacePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'จัดการเวลา',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'เลือกสถานที่',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'เลือกสถานที่เพื่อกำหนดเวลา',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            SlidePlace(),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'กำหนดเวลา',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'ระบุเวลาการเดินทางของแต่ละสถานที่',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 7),
            SlideTime(),
            SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'การกำหนดการเวลาแต่ละสถานที่',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PlaceSum(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TimePlacePage(),
  ));
}
