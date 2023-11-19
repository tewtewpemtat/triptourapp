import 'package:flutter/material.dart';

class UserButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          SizedBox(height: 8),
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
                      IconButton(
                        icon: Icon(Icons.mail),
                        onPressed: () {
                          // ทำอะไรสักอย่างเมื่อกด icon อีเมล
                        },
                      ),
                      // รูปไอคอนแชท
                      // ระยะห่างระหว่างไอคอนแชทและข้อความ
                      Text('ร้องขอสถานที่'),
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
      home: UserButton(),
    ),
  );
}
