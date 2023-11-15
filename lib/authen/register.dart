import 'package:flutter/material.dart';
import 'login.dart';

class RegisterPage extends StatelessWidget {
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginPage()), // RegisterPage() คือหน้าที่คุณต้องไป
                      );
                    },
                    child: Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    // เพิ่มโค้ดสำหรับสมัครสมาชิก
                  },
                  child: Text(
                    'สมัครสมาชิก',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text('เข้าสู่ระบบเพื่อเข้าใช้งานเเอปพลิเคชั่น Trip Tour',
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 15),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'อีเมล',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'เบอร์โทรศัพท์',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // เพิ่มโค้ดสำหรับ Sign in
              },
              child: Text('ดำเนินการต่อ'),
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
      home: RegisterPage(),
    ),
  );
}
