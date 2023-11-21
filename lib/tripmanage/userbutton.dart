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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'แผนการเดินทาง',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    'ออกจากทริป',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // สามารถกำหนดสีข้อความเพิ่มเติมได้ที่นี่ถ้าต้องการ
                    ),
                  ),
                )
              ],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chat),
                        onPressed: () {
                          // ทำอะไรสักอย่างเมื่อกด icon อีเมล
                        },
                      ),
                      // รูปไอคอนแชท
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
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
                      SizedBox(width: 8), // ระยะห่างระหว่างไอคอนแชทและข้อความ
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
