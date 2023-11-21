import 'package:flutter/material.dart';
import 'timeline/timeline_history.dart';
import 'main/top_navbar.dart';
import 'main/bottom_navbar.dart';

void main() {
  runApp(TripTimeLine());
}

class TripTimeLine extends StatelessWidget {
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
              TripTimeLineHistory(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          selectedIndex: 2,
          onItemTapped: (index) {
            // โค้ดที่จะทำเมื่อผู้ใช้แตะที่ BottomNavbar
          },
        ),
      ),
    );
  }
}
