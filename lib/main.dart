import 'package:flutter/material.dart';
import 'package:triptourapp/authen/login.dart';
import 'main/bottom_navbar.dart';
import 'main/top_navbar.dart';
import 'main/tripbutton.dart';
import 'main/triphistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      home: LoginPage(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTour',
      home: Scaffold(
        appBar: TopNavbar(), // เรียกใช้ TopNavbar Widgetna
        resizeToAvoidBottomInset: false, // เพิ่มการตั้งค่านี้
        body: SingleChildScrollView(
          child: Column(
            children: [
              TripButtons(),
              TripHistory(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          selectedIndex: 0,
          onItemTapped: (index) {
            // โค้ดที่จะทำเมื่อผู้ใช้แตะที่ BottomNavbar
          },
        ),
      ),
    );
  }
}
