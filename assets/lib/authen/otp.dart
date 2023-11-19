import 'package:flutter/material.dart';
import 'newpassword.dart';

class OtpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'TripTour',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start, // จัดตำแหน่งให้ Text อยู่ตรงกลาง
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // ตำแหน่งปุ่มจะอยู่ทางด้านซ้าย
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 0.0), // ระยะห่างทางด้านขวาของปุ่ม
                  child: InkWell(
                    onTap: () {
                      // เพิ่มโค้ดสำหรับเข้าสู่ระบบ
                    },
                    child: Text(
                      'ยืนยัน OTP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text('โปรดรอรับ OTP ภายใน 5 นาที', style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'กรอกรหัส OTP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // เพิ่มโค้ด
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewpasswordPage()), // RegisterPage() คือหน้าที่คุณต้องไป
                );
              },
              child: Text('ดำเนินการต่อ'),
            ),
            SizedBox(height: 5),
            TextButton(
              onPressed: () {
                // เพิ่มโค้ดสำหรับลืมรหัสผ่าน
              },
              child: Text('ส่งรหัส OTP อีกครั้ง'),
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
      home: OtpPage(),
    ),
  );
}
