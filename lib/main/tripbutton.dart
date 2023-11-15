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
              'สร้างทริปของคุณ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              // ไปยังหน้าสร้างทริป
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.all(16),
            ),
            child: Text(
              'สร้างทริป',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              // ไปยังหน้าเข้าร่วมทริป
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              padding: EdgeInsets.all(16),
            ),
            child: Text(
              'เข้าร่วมทริป',
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
