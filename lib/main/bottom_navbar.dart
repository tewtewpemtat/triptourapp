import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('receiverUid',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('status', isEqualTo: 'Unread')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          int unreadMessagesCount = snapshot.data?.docs.length ?? 0;
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'หน้าหลัก',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(Icons.people),
                    if (unreadMessagesCount > 0)
                      Positioned(
                        top: -10, // ปรับตำแหน่งตามต้องการ
                        right: -10.5, // ปรับตำแหน่งตามต้องการ
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$unreadMessagesCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'เพื่อน',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timeline),
                label: 'ประวัติทริป',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: (index) {
              if (index == 0) {
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
                onItemTapped(index);
              }
            },
          );
        }
      },
    );
  }
}
