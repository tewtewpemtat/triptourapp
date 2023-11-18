import 'package:flutter/material.dart';

class HeadbuttonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Text(
                'แผนการเดินทาง',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ทำอะไรเมื่อกดปุ่มแชท
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // สีพื้นหลังของปุ่ม
                      onPrimary: Colors.black, // สีขอบตัวอักษร
                      fixedSize: Size(200, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat), // รูปไอคอนแชท
                        SizedBox(width: 8), // ระยะห่างระหว่างไอคอนแชทและข้อความ
                        Text('แชทกลุ่ม'),
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
                      // ทำอะไรเมื่อกดปุ่มเพิ่มสถานที่
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      fixedSize: Size(200, 50),
                    ),
                    child: Text('เพิ่มสถานที่'),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ทำอะไรเมื่อกดปุ่มกำหนดเวลาแต่ละสถานที่
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      fixedSize: Size(200, 50),
                    ),
                    child: Text('กำหนดเวลาแต่ละสถานที่'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: HeadbuttonPage(),
    ),
  );
}
