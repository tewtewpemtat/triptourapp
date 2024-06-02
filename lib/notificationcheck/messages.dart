import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triptourapp/service/notification.dart';

class messagesCheck extends StatelessWidget {
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
          return Container();
        } else if (snapshot.hasError) {
          return Container();
        } else {
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

          return Container();
        }
      },
    );
  }
}
