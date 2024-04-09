import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triptourapp/SetProfile.dart';
import './firebase_auth_implementation/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'forget.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService auth = FirebaseAuthService();

  bool _isSigningIn =
      false; // เปลี่ยนชื่อตัวแปรเป็น _isSigningIn เพื่อให้เหมาะสมกับการล็อกอิน

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyApp(),
                        ),
                      );
                    },
                    child: Text(
                      'เข้าสู่ระบบ',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    'สมัครสมาชิก',
                    style: GoogleFonts.ibmPlexSansThai(fontSize: 24),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              'เข้าสู่ระบบเพื่อเข้าใช้งานแอปพลิเคชัน Trip Tour',
              style: GoogleFonts.ibmPlexSansThai(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
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
            SizedBox(height: 10),
            TextFormField(
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
            SizedBox(height: 20),
            Container(
              width: 184,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffdb923c),
              ),
              child: TextButton(
                onPressed: _isSigningIn ? null : () => _signIn(context),
                child: _isSigningIn
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'เข้าสู่ระบบ',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgetPage(),
                  ),
                );
              },
              child: Text(
                'ลืมรหัสผ่าน',
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

  void _signIn(BuildContext context) async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: 'โปรดกรอกข้อมูลให้ครบถ้วน');
    } else {
      if (mounted)
        setState(() {
          _isSigningIn = true;
        });
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          print("Successfully signed In");
          String? uid = user.uid;

          DocumentSnapshot<Map<String, dynamic>> userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get();

          String profileStatus = userDoc.get('profileStatus');

          if (profileStatus == 'None') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SetProfilePage(),
              ),
            );
          } else if (profileStatus == 'Completed') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ),
            );
          }
        }
      } catch (e) {
      } finally {
        if (mounted)
          setState(() {
            _isSigningIn = false;
          });
      }
    }
  }
}

void main() async {
  runApp(
    MaterialApp(
      home: LoginPage(),
    ),
  );
}
