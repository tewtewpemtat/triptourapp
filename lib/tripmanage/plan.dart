import 'package:flutter/material.dart';

class TripButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.all(10), // ระยะห่างระหว่างปุ่ม
          child: Align(
            alignment: Alignment.centerLeft, // จัดตำแหน่งข้อความไปทางซ้าย

            child: Text(
              'แผนการเดินทาง',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffdb923c),
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              primary: Color(0xffdb923c), // ให้สีปุ่มเท่ากับสีของ Container
              padding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'แชทกลุ่ม',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffdb923c),
          ),
          child: ElevatedButton(
            onPressed: () {
              // ไปยังหน้าเข้าร่วมทริป
            },
            style: ElevatedButton.styleFrom(
              primary: Color(
                  0xffdb923c), // ให้สีเหมือนกับสีของ Container ที่ใช้ในการสร้างทริป
              padding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'เพิ่มสถานที่',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffdb923c),
          ),
          child: ElevatedButton(
            onPressed: () {
              // ไปยังหน้าเข้าร่วมทริป
            },
            style: ElevatedButton.styleFrom(
              primary: Color(
                  0xffdb923c), // ให้สีเหมือนกับสีของ Container ที่ใช้ในการสร้างทริป
              padding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'จัดการเวลาสถานที่',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: TripButtons(),
        ),
      ),
    ),
  );
}
