import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuthService auth = FirebaseAuthService();

  bool _isSigningUp = false;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _passwordController2 = new TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordController2.dispose();
  }

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'เข้าสู่ระบบ',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                InkWell(
                  onTap: () {},
                  child: Text(
                    'สมัครสมาชิก',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text('สมัครสมาชิกเพื่อเข้าใช้งานแอปพลิเคชัน Trip Tour',
                style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 12, color: Colors.grey)),
            SizedBox(height: 15),
            Container(
              width: 339,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'อีเมล',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFFEE8B60),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 339,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFFEE8B60),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 339,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: TextFormField(
                obscureText: true,
                controller: _passwordController2,
                decoration: InputDecoration(
                  labelText: 'ยืนยันรหัสผ่าน',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFFEE8B60),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 184,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffdb923c),
              ),
              child: TextButton(
                onPressed: () {
                  _signup(context);
                },
                child: _isSigningUp
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'ดำเนินการต่อ',
                        style: GoogleFonts.ibmPlexSansThai(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signup(BuildContext context) async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _passwordController2.text;
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: 'โปรดกรอกข้อมูลให้ครบถ้วน');
    } else if (password.length < 6) {
      Fluttertoast.showToast(msg: 'รหัสผ่านต้องมากกว่า 6 ตัวขึ้นไป');
    } else if (password != confirmPassword) {
      Fluttertoast.showToast(msg: 'รหัสผ่านไม่ตรงกัน');
    } else {
      setState(() {
        _isSigningUp = true;
      });
      User? user = await auth.signUpWithEmailAndPassword(email, password);
      setState(() {
        _isSigningUp = false;
      });
      if (user != null) {
        print("Successfully signed up");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
        Fluttertoast.showToast(msg: 'สร้างบัญชีสำเร็จ');
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      home: RegisterPage(),
    ),
  );
}
