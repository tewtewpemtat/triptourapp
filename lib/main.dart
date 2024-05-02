import 'package:flutter/material.dart';
import 'package:triptourapp/authen/login.dart';
import 'main/bottom_navbar.dart';
import 'main/top_navbar.dart';
import 'main/tripbutton.dart';
import 'main/triphistory.dart';
import 'package:intl/date_symbol_data_local.dart'; // import เพิ่มเติม
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash.dart';

void main() async {
  initializeDateFormatting('th', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      home: AuthenticationWrapper(),
    ),
  );
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ถ้ายังไม่ได้ตรวจสอบสถานะผู้ใช้ ให้แสดงหน้าโหลด
            return Container();
          } else {
            if (snapshot.hasData) {
              // ถ้ามีผู้ใช้ล็อกอิน ให้ไปยังหน้า Main
              return MyApp();
            } else {
              // ถ้าไม่มีผู้ใช้ล็อกอิน ให้ไปยังหน้า Login
              return LoginPage();
            }
          }
        } catch (error) {
          // รับข้อผิดพลาดที่เกิดขึ้น
          print("Error: $error");
          // สามารถแสดงข้อความหรือทำการรีเซ็ตแอปพลิเคชัน
          // ที่นี่ตามที่ต้องการ
          // เช่นแสดงข้อความเตือนหรือทำการรีเซ็ตแอปพลิเคชัน
        }
        // Add a return statement here to satisfy the requirement of the function
        // เพิ่มคำสั่ง return ที่นี่เพื่อทำให้ระบบพบว่าฟังก์ชันจบด้วยการ return หรือ throw
        return Container(); // For example, return an empty Container
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTour',
      home: Scaffold(
        appBar: TopNavbar(), // เรียกใช้ TopNavbar Widget
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
