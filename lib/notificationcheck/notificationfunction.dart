import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triptourapp/notificationsend.dart';

Future<void> addFriendNotification(String friendUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  String firstName = userDoc['firstName'];
  String lastName = userDoc['lastName'];

  QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
      .collection('usersToken')
      .where('userId', isEqualTo: friendUid)
      .get();

  if (friendTokenQuery.docs.isNotEmpty) {
    String token = friendTokenQuery.docs.first['token'];

    await sendNotification(
      token,
      'เเจ้งเตือน',
      '$firstName $lastName ส่งคำขอเป็นเพื่อนถึงคุณ',
    );
  } else {
    print('Friend token not found');
  }
}

Future<void> InviteTripNotification(String friendUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  String firstName = userDoc['firstName'];
  String lastName = userDoc['lastName'];

  QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
      .collection('usersToken')
      .where('userId', isEqualTo: friendUid)
      .get();

  if (friendTokenQuery.docs.isNotEmpty) {
    String token = friendTokenQuery.docs.first['token'];

    await sendNotification(
      token,
      'เเจ้งเตือน',
      '$firstName $lastName ได้เชิญคุณเข้าร่วมทริป',
    );
  } else {
    print('Friend token not found');
  }
}

Future<void> chatSendNotification(String friendUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  String firstName = userDoc['firstName'];
  String lastName = userDoc['lastName'];

  QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
      .collection('usersToken')
      .where('userId', isEqualTo: friendUid)
      .get();

  if (friendTokenQuery.docs.isNotEmpty) {
    String token = friendTokenQuery.docs.first['token'];

    await sendNotification(
      token,
      'Message',
      'คุณมีข้อความใหม่จาก $firstName $lastName',
    );
  } else {
    print('Friend token not found');
  }
}

Future<void> cancelTripNotification(String tripUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    List<dynamic> tripJoin = tripDoc['tripJoin'] ?? [];

    if (tripJoin.isNotEmpty) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];

      for (String participantUid in tripJoin) {
        if (participantUid != uid) {
          QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
              .collection('usersToken')
              .where('userId', isEqualTo: participantUid)
              .get();

          if (friendTokenQuery.docs.isNotEmpty) {
            String token = friendTokenQuery.docs.first['token'];

            await sendNotification(
              token,
              'ทริป ${tripDoc['tripName']}',
              'ถูกยกเลิกเนื่องจาก ${tripDoc['tripRemark']}',
            );
          } else {
            print('Token not found for user: $participantUid');
          }
        }
      }
    } else {
      print('No participants found in tripJoin');
    }
  } else {
    print('Trip not found');
  }
}

Future<void> leaveTripNotification(String tripUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    String tripCreate = tripDoc['tripCreate'];

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    String firstName = userDoc['firstName'];
    String lastName = userDoc['lastName'];

    QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
        .collection('usersToken')
        .where('userId', isEqualTo: tripCreate)
        .get();

    if (friendTokenQuery.docs.isNotEmpty) {
      String token = friendTokenQuery.docs.first['token'];

      await sendNotification(
        token,
        'ทริป ${tripDoc['tripName']}',
        '$firstName $lastName ได้ออกจากทริป',
      );
    } else {
      print('Token not found for user');
    }
  } else {
    print('Trip not found');
  }
}

Future<void> joinTripNotification(String tripUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    String tripCreate = tripDoc['tripCreate'];

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    String firstName = userDoc['firstName'];
    String lastName = userDoc['lastName'];

    QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
        .collection('usersToken')
        .where('userId', isEqualTo: tripCreate)
        .get();

    if (friendTokenQuery.docs.isNotEmpty) {
      String token = friendTokenQuery.docs.first['token'];

      await sendNotification(
        token,
        'ทริป ${tripDoc['tripName']}',
        '$firstName $lastName ได้เข้าร่วมทริป',
      );
    } else {
      print('Token not found for user');
    }
  } else {
    print('Trip not found');
  }
}

Future<void> requestPlaceNotification(String tripUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    String tripCreate = tripDoc['tripCreate'];

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    String firstName = userDoc['firstName'];
    String lastName = userDoc['lastName'];

    QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
        .collection('usersToken')
        .where('userId', isEqualTo: tripCreate)
        .get();

    if (friendTokenQuery.docs.isNotEmpty) {
      String token = friendTokenQuery.docs.first['token'];

      await sendNotification(
        token,
        'ทริป ${tripDoc['tripName']}',
        '$firstName $lastName ได้แนะนำสถานที่ใหม่',
      );
    } else {
      print('Token not found for user');
    }
  } else {
    print('Trip not found');
  }
}

Future<void> tripUpdatePlanNotification(String tripUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    List<dynamic> tripJoin = tripDoc['tripJoin'] ?? [];

    if (tripJoin.isNotEmpty) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];

      for (String participantUid in tripJoin) {
        if (participantUid != uid) {
          QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
              .collection('usersToken')
              .where('userId', isEqualTo: participantUid)
              .get();

          if (friendTokenQuery.docs.isNotEmpty) {
            String token = friendTokenQuery.docs.first['token'];

            await sendNotification(
              token,
              'ทริป ${tripDoc['tripName']}',
              'มีการอัพเดทแผนการเดินทางใหม่',
            );
          } else {
            print('Token not found for user: $participantUid');
          }
        }
      }
    } else {
      print('No participants found in tripJoin');
    }
  } else {
    print('Trip not found');
  }
}

Future<void> tripInterestNotification(String tripUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    List<dynamic> tripJoin = tripDoc['tripJoin'] ?? [];

    if (tripJoin.isNotEmpty) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];

      for (String participantUid in tripJoin) {
        if (participantUid != uid) {
          QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
              .collection('usersToken')
              .where('userId', isEqualTo: participantUid)
              .get();

          if (friendTokenQuery.docs.isNotEmpty) {
            String token = friendTokenQuery.docs.first['token'];

            await sendNotification(
              token,
              'ทริป ${tripDoc['tripName']}',
              '$firstName $lastName ได้เพิ่มสิ่งน่าสนใจใหม่',
            );
          } else {
            print('Token not found for user: $participantUid');
          }
        }
      }
    } else {
      print('No participants found in tripJoin');
    }
  } else {
    print('Trip not found');
  }
}

Future<void> tripMeetNotification(String tripUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    List<dynamic> tripJoin = tripDoc['tripJoin'] ?? [];

    if (tripJoin.isNotEmpty) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];

      for (String participantUid in tripJoin) {
        if (participantUid != uid) {
          QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
              .collection('usersToken')
              .where('userId', isEqualTo: participantUid)
              .get();

          if (friendTokenQuery.docs.isNotEmpty) {
            String token = friendTokenQuery.docs.first['token'];

            await sendNotification(
              token,
              'ทริป ${tripDoc['tripName']}',
              '$firstName $lastName ได้เพิ่มจุดนัดพบใหม่',
            );
          } else {
            print('Token not found for user: $participantUid');
          }
        }
      }
    } else {
      print('No participants found in tripJoin');
    }
  } else {
    print('Trip not found');
  }
}

Future<void> placeRunNotification(String tripUid, String placeUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  DocumentSnapshot placeDoc =
      await FirebaseFirestore.instance.collection('places').doc(placeUid).get();

  if (tripDoc.exists) {
    if (placeDoc.exists) {
      List<dynamic> tripJoin = tripDoc['tripJoin'] ?? [];

      if (tripJoin.isNotEmpty) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        String firstName = userDoc['firstName'];
        String lastName = userDoc['lastName'];

        for (String participantUid in tripJoin) {
          QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
              .collection('usersToken')
              .where('userId', isEqualTo: participantUid)
              .get();

          if (friendTokenQuery.docs.isNotEmpty) {
            String token = friendTokenQuery.docs.first['token'];

            await sendNotification(
              token,
              'ทริป ${tripDoc['tripName']}',
              'สถานที่ ${placeDoc['placename']} กำลังดำเนินการ',
            );
          } else {
            print('Token not found for user: $participantUid');
          }
        }
      } else {
        print('No participants found in tripJoin');
      }
    }
  } else {
    print('Trip not found');
  }
}

Future<void> placeEndNotification(String tripUid, String placeUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  DocumentSnapshot placeDoc =
      await FirebaseFirestore.instance.collection('places').doc(placeUid).get();

  if (tripDoc.exists) {
    if (placeDoc.exists) {
      List<dynamic> tripJoin = tripDoc['tripJoin'] ?? [];

      if (tripJoin.isNotEmpty) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        String firstName = userDoc['firstName'];
        String lastName = userDoc['lastName'];

        for (String participantUid in tripJoin) {
          QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
              .collection('usersToken')
              .where('userId', isEqualTo: participantUid)
              .get();

          if (friendTokenQuery.docs.isNotEmpty) {
            String token = friendTokenQuery.docs.first['token'];

            await sendNotification(
              token,
              'ทริป ${tripDoc['tripName']}',
              'สถานที่ ${placeDoc['placename']} สิ้นสุดเเล้ว',
            );
          } else {
            print('Token not found for user: $participantUid');
          }
        }
      } else {
        print('No participants found in tripJoin');
      }
    }
  } else {
    print('Trip not found');
  }
}

Future<void> tripRunNotification(String tripUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    List<dynamic> tripJoin = tripDoc['tripJoin'] ?? [];

    if (tripJoin.isNotEmpty) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];

      for (String participantUid in tripJoin) {
        QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
            .collection('usersToken')
            .where('userId', isEqualTo: participantUid)
            .get();

        if (friendTokenQuery.docs.isNotEmpty) {
          String token = friendTokenQuery.docs.first['token'];

          await sendNotification(
            token,
            'ทริป ${tripDoc['tripName']}',
            'กำลังดำเนินการ',
          );
        } else {
          print('Token not found for user: $participantUid');
        }
      }
    } else {
      print('No participants found in tripJoin');
    }
  } else {
    print('Trip not found');
  }
}

Future<void> tripEndNotification(String tripUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    List<dynamic> tripJoin = tripDoc['tripJoin'] ?? [];

    if (tripJoin.isNotEmpty) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];

      for (String participantUid in tripJoin) {
        QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
            .collection('usersToken')
            .where('userId', isEqualTo: participantUid)
            .get();

        if (friendTokenQuery.docs.isNotEmpty) {
          String token = friendTokenQuery.docs.first['token'];

          await sendNotification(
            token,
            'ทริป ${tripDoc['tripName']}',
            'สิ้นสุดเเล้ว',
          );
        } else {
          print('Token not found for user: $participantUid');
        }
      }
    } else {
      print('No participants found in tripJoin');
    }
  } else {
    print('Trip not found');
  }
}

Future<void> joinPlaceNotification(String tripUid, String placeUid) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  DocumentSnapshot placeDoc =
      await FirebaseFirestore.instance.collection('places').doc(placeUid).get();

  if (tripDoc.exists) {
    if (placeDoc.exists) {
      String tripCreate = tripDoc['tripCreate'];

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];

      QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
          .collection('usersToken')
          .where('userId', isEqualTo: tripCreate)
          .get();

      if (friendTokenQuery.docs.isNotEmpty) {
        String token = friendTokenQuery.docs.first['token'];

        await sendNotification(
          token,
          'ทริป ${tripDoc['tripName']}',
          '$firstName $lastName เข้าร่วมสถานที่ ${placeDoc['placename']}',
        );
      } else {
        print('Token not found for user: $tripCreate');
      }
    } else {
      print('No participants found in tripJoin');
    }
  }
}

Future<void> groupChatNotification(String tripUid, String message) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot tripDoc =
      await FirebaseFirestore.instance.collection('trips').doc(tripUid).get();

  if (tripDoc.exists) {
    List<dynamic> tripJoin = tripDoc['tripJoin'] ?? [];

    if (tripJoin.isNotEmpty) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];

      for (String participantUid in tripJoin) {
        if (participantUid != uid) {
          QuerySnapshot friendTokenQuery = await FirebaseFirestore.instance
              .collection('usersToken')
              .where('userId', isEqualTo: participantUid)
              .get();

          if (friendTokenQuery.docs.isNotEmpty) {
            String token = friendTokenQuery.docs.first['token'];
            if (message == 'Pic') {
              await sendNotification(
                token,
                'ทริป ${tripDoc['tripName']}',
                '$firstName $lastName ส่งรูปภาพ',
              );
            } else {
              await sendNotification(
                token,
                'ทริป ${tripDoc['tripName']}',
                '$firstName $lastName : $message',
              );
            }
          } else {
            print('Token not found for user: $participantUid');
          }
        }
      }
    } else {
      print('No participants found in tripJoin');
    }
  } else {
    print('Trip not found');
  }
}
