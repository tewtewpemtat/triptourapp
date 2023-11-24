import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/createtrip.dart';
import 'package:triptourapp/jointrip.dart';

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
              style: GoogleFonts.ibmPlexSansThai(
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTripPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xffdb923c), // ให้สีปุ่มเท่ากับสีของ Container
              padding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'สร้างทริป',
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JoinTripPage(),
                ),
              );
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
