import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/addplace.dart';
import 'package:triptourapp/groupchat.dart';

import '../timeplace.dart';

class HeadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'แผนการเดินทาง',
                    style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // ทำสิ่งที่ต้องการเมื่อคลิกที่ปุ่ม
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red, // กำหนดสีพื้นหลังเป็นสีแดง
                    primary: Colors.white, // กำหนดสีของตัวอักษรเป็นสีขาว
                  ),
                  child: Text(
                    'ยกเลิกทริป',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // สามารถกำหนดสีข้อความเพิ่มเติมได้ที่นี่ถ้าต้องการ
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
                        builder: (context) => GroupScreenPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // สีพื้นหลังของปุ่ม
                    onPrimary: Colors.black, // สีขอบตัวอักษร
                    fixedSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat), // รูปไอคอนแชท
                      SizedBox(width: 8), // ระยะห่างระหว่างไอคอนแชทและข้อความ
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
          SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    fixedSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on), // รูปไอคอนแชท
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
              SizedBox(width: 5),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimePlacePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    fixedSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time), // รูปไอคอนแชท
                      SizedBox(width: 2),
                      Text(
                        'กำหนดเวลาแต่ละสถานที่',
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
  }
}

void main() {
  runApp(
    MaterialApp(
      home: HeadButton(),
    ),
  );
}
