import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triptourapp/friend.dart';
import 'package:triptourapp/service/notification.dart';
import 'package:triptourapp/triptimeline.dart';
import 'package:triptourapp/main.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  BottomNavbar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  Future<Map<String, String>> _getSenderInfo(String senderUid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderUid)
        .get();
    String firstName = userDoc['firstName'];
    String lastName = userDoc['lastName'];
    return {'firstName': firstName, 'lastName': lastName};
  }

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

          bool shouldSendNotification = false;
          String? latestSenderUid;

          for (DocumentSnapshot doc in snapshot.data!.docs) {
            String sendStatus = doc['sendStatus'];
            if (sendStatus == 'no') {
              shouldSendNotification = true;
              doc.reference.update({'sendStatus': 'yes'});
              latestSenderUid = doc['senderUid'];
            }
          }

          if (shouldSendNotification && latestSenderUid != null) {
            _getSenderInfo(latestSenderUid).then((senderInfo) {
              NotificationService().showNotification(
                title: 'แจ้งเตือน',
                body:
                    'คุณมีข้อความใหม่จาก ${senderInfo['firstName']} ${senderInfo['lastName']}',
              );
            });
          }

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
                        top: -10,
                        right: -10.5,
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
