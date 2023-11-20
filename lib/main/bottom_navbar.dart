import 'package:flutter/material.dart';
import 'package:triptourapp/friend.dart';
import 'package:triptourapp/triptimeline.dart';
import 'package:triptourapp/main.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  BottomNavbar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'หน้าหลัก',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'เพื่อน',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline),
          label: 'ไทมไลน์ทริป',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == 0) {
          // ถ้า index เท่ากับ 0 (หน้าหลัก), ให้เปลี่ยนไปที่หน้า MainPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        }
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Friend()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TripTimeLine()),
          );
        } else {
          // ถ้าไม่ใช่หน้าหลักหรือไทมไลน์ทริป, ให้เรียก callback onItemTapped
          onItemTapped(index);
        }
      },
    );
  }
}
