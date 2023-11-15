import 'package:flutter/material.dart';
import 'login.dart';

class ForgetPage extends StatelessWidget {
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
                      'ลืมรหัสผ่าน',
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
            Text('กรอกหมายเลขโทรศัพทที่ใช้สมัครสมาชิกกับ Trip Tour',
                style: TextStyle(fontSize: 12)),
            Text('เราจะส่งOTPสำหรับเเก้ไขรหัสผ่านหมายเลขโทรศัพท์ของท่าน',
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'ระบุเบอร์โทรศัพท์',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // เพิ่มโค้ด
              },
              child: Text('ดำเนินการต่อ'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // เพิ่มโค้ดสำหรับลืมรหัสผ่าน
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // RegisterPage() คือหน้าที่คุณต้องไป
                );
              },
              child: Text('หากมีสมาชิกอยู่เเล้ว กดที่นี่เพื่อเข้าสู่ระบบ'),
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
      home: ForgetPage(),
    ),
  );
}
