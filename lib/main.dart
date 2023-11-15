import 'package:flutter/material.dart';
import 'main/bottom_navbar.dart';
import 'main/tripbutton.dart';
import 'main/top_navbar.dart';
import 'main/triphistory.dart';
import 'starter.dart';

void main() {
  runApp(Starter());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTour',
      home: Scaffold(
        appBar: TopNavbar(), // เรียกใช้ TopNavbar Widget
        resizeToAvoidBottomInset: false, // เพิ่มการตั้งค่านี้
        body: Stack(
          children: [
            Column(
              children: [
                TripButtons(),
                TripHistory(),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavbar(
                selectedIndex: 0,
                onItemTapped: (index) {
                  // โค้ดที่จะทำเมื่อผู้ใช้แตะที่ BottomNavbar
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
