import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/authen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'otp.dart';

class ForgetPage extends StatefulWidget {
  @override
  _ForgetPageState createState() => _ForgetPageState();
}

class _ForgetPageState extends State<ForgetPage> {
  final FirebaseAuthService auth = FirebaseAuthService();
  TextEditingController forgetPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Trip',
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.start,
                ),
                Text(
                  'Tour',
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE59730),
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
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
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text('กรอกอีเมลที่ใช้สมัครสมาชิกกับ Trip Tour',
                style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 12, color: Colors.grey)),
            Text('เราจะส่งลิ้งสำหรับเเก้ไขรหัสผ่านอีเมลของท่าน',
                style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 12, color: Colors.grey)),
            SizedBox(height: 20),
            TextFormField(
              controller: forgetPasswordController,
              decoration: InputDecoration(
                labelText: 'ระบุอีเมล',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              width: 184,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffdb923c),
              ),
              child: TextButton(
                onPressed: () {
                  var forgotEmail = forgetPasswordController.text.trim();
                  if (forgotEmail.isNotEmpty && isValidEmail(forgotEmail)) {
                    try {
                      FirebaseAuth.instance
                          .sendPasswordResetEmail(email: forgotEmail)
                          .then((value) {
                        Fluttertoast.showToast(
                            msg: 'ส่งลิ้งไปบนอีเมลเรียบร้อยเเล้ว');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      });
                    } on FirebaseAuthException catch (e) {
                      print("Error");
                    }
                  } else {
                    Fluttertoast.showToast(msg: 'กรุณากรอกอีเมลให้ถูกต้อง');
                  }
                },
                child: Text(
                  'ดำเนินการต่อ',
                  style: GoogleFonts.ibmPlexSansThai(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
              child: Text(
                'หากมีสมาชิกอยู่เเล้ว กดที่นี่เพื่อเข้าสู่ระบบ',
                style: GoogleFonts.ibmPlexSansThai(
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool isValidEmail(String email) {
  // ในที่นี้เราใช้ regex เพื่อตรวจสอบรูปแบบของอีเมล
  // คุณสามารถปรับแต่งตามความต้องการของคุณ
  String emailRegex = r'^[\w-]+(?:\.[\w-]+)*@(?:[\w-]+\.)+[a-zA-Z]{2,7}$';
  RegExp regex = RegExp(emailRegex);
  return regex.hasMatch(email);
}

void main() {
  runApp(
    MaterialApp(
      home: ForgetPage(),
    ),
  );
}
