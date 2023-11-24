import 'package:flutter/material.dart';
import 'main/bottom_navbar.dart';
import 'main/top_navbar.dart';
import 'main/tripbutton.dart';
import 'main/triphistory.dart';
import 'splash.dart';

void main() {
  runApp(splash());
}

class MyApp extends StatelessWidget {
  @override
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
