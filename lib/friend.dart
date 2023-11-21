import 'package:flutter/material.dart';
import 'package:triptourapp/friend/friendbutton.dart';
import 'package:triptourapp/friend/friendlist.dart';
import 'main/top_navbar.dart';
import 'main/bottom_navbar.dart';

void main() {
  runApp(Friend());
}

class Friend extends StatelessWidget {
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
              FriendButton(),
              FriendList(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          selectedIndex: 1,
          onItemTapped: (index) {
            // โค้ดที่จะทำเมื่อผู้ใช้แตะที่ BottomNavbar
          },
        ),
      ),
    );
  }
}
