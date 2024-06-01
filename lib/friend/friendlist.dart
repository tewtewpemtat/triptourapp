import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triptourapp/addfriend.dart';
import 'package:triptourapp/friendrequest.dart';
import '../privatechat.dart';
import 'package:intl/intl.dart';

class FriendList extends StatefulWidget {
  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? myUid = FirebaseAuth.instance.currentUser?.uid;

  Stream<int> countrequest() async* {
    try {
      final collection = FirebaseFirestore.instance.collection('friendrequest');

      final stream = collection
          .where('receiverUid', isEqualTo: myUid)
          .where('status', isEqualTo: 'Wait')
          .snapshots();

      await for (QuerySnapshot querySnapshot in stream) {
        yield querySnapshot.size;
      }
    } catch (e) {
      print('Error counting unread messages: $e');
      yield 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffeaeaea),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'ค้นหาเพื่อนของคุณ',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFriend(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 10),
                      Text('เพิ่มเพื่อน',
                          style: GoogleFonts.ibmPlexSansThai(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendRequestPage(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Icon(Icons.mail),
                    StreamBuilder<int>(
                      stream: countrequest(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        int unreadCount = snapshot.data ?? 0;
                        return unreadCount != 0
                            ? Positioned(
                                top: -10,
                                right: -10.5,
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 15,
                                    minHeight: 15,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : SizedBox();
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 10),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(myUid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text(''));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('ไม่พบเพื่อน'));
            }

            Map<String, dynamic>? userData =
                snapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null || !userData.containsKey('friendList')) {
              return Center(child: Text('ไม่พบเพื่อน'));
            }

            List<dynamic> friendList = userData['friendList'];

            if (friendList.isEmpty) {
              return Center(child: Text('ไม่พบเพื่อน'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: friendList.length,
              itemBuilder: (context, index) {
                String friendUid = friendList[index];
                return buildFriendItem(context, friendUid);
              },
            );
          },
        ),
      ],
    );
  }

  void markMessagesAsRead(String friendUid) {
    try {
      CollectionReference chatsCollection =
          FirebaseFirestore.instance.collection('messages');

      chatsCollection
          .where('receiverUid', isEqualTo: myUid)
          .where('senderUid', isEqualTo: friendUid)
          .where('status', isEqualTo: 'Unread')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          chatsCollection.doc(doc.id).update({'status': 'Read'});
        });
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Widget buildFriendItem(BuildContext context, String friendUid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Icon(Icons.error);
        }

        Map<String, dynamic>? friendData =
            snapshot.data!.data() as Map<String, dynamic>?;

        if (friendData == null) {
          return Icon(Icons.error);
        }

        String fullName = '${friendData['firstName']} ${friendData['lastName']}'
            .toLowerCase();
        bool matchesSearch = fullName.contains(_searchQuery);

        if (_searchQuery.isEmpty || matchesSearch) {
          return Material(
            child: InkWell(
              onTap: () {
                markMessagesAsRead(friendUid);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreenPage(friendUid: friendUid),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.all(4.0),
                            child: ClipOval(
                              child: Image.network(
                                friendData['profileImageUrl'] ??
                                    'https://example.com/default-profile-image.jpg',
                                width: 70.0,
                                height: 70.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          flex: 7,
                          child: Container(
                            margin: EdgeInsets.only(top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${friendData['firstName']} ${friendData['lastName']}',
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                buildLastMessageWidget(friendUid),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: StreamBuilder<int>(
                              stream: countUnreadMessages(friendUid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                int unreadCount = snapshot.data ?? 0;
                                return unreadCount != 0
                                    ? Container(
                                        margin: EdgeInsets.only(top: 25.0),
                                        width: 28.0,
                                        height: 30.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromARGB(255, 251, 2, 2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            unreadCount.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Stream<int> countUnreadMessages(String friendUid) async* {
    try {
      final collection = FirebaseFirestore.instance.collection('messages');

      final stream = collection
          .where('receiverUid', isEqualTo: myUid)
          .where('senderUid', isEqualTo: friendUid)
          .where('status', isEqualTo: 'Unread')
          .snapshots();

      await for (QuerySnapshot querySnapshot in stream) {
        yield querySnapshot.size;
      }
    } catch (e) {
      print('Error counting unread messages: $e');
      yield 0;
    }
  }

  Stream<Widget> streamLastMessageAndDisplay(String friendUid) async* {
    try {
      final collection = FirebaseFirestore.instance.collection('chats');

      final stream1 = collection
          .where('receiverUid', isEqualTo: friendUid)
          .where('senderUid', isEqualTo: myUid)
          .orderBy('timestampserver', descending: true)
          .snapshots();

      final stream2 = collection
          .where('receiverUid', isEqualTo: myUid)
          .where('senderUid', isEqualTo: friendUid)
          .orderBy('timestampserver', descending: true)
          .snapshots();

      await for (QuerySnapshot querySnapshot1 in stream1) {
        await for (QuerySnapshot querySnapshot2 in stream2) {
          List<DocumentSnapshot> documents = [
            ...querySnapshot1.docs,
            ...querySnapshot2.docs,
          ];

          documents.sort((a, b) {
            Timestamp timestampA = a['timestampserver'];
            Timestamp timestampB = b['timestampserver'];
            return timestampB.compareTo(timestampA);
          });

          if (documents.isNotEmpty) {
            DocumentSnapshot latestMessage = documents.first;
            String messageText = latestMessage['lastMessage'] ?? '';
            String justmessage = messageText.length > 20
                ? messageText.substring(0, 20)
                : messageText;
            if (justmessage.length > 17) {
              justmessage += '...';
            }

            String senderUid = latestMessage['senderUid'];
            Timestamp timestamp = latestMessage['timestampserver'];
            String formattedTime =
                DateFormat('HH:mm').format(timestamp.toDate());

            String displayMessage = senderUid != myUid
                ? 'เพื่อน: $justmessage $formattedTime'
                : 'คุณ: $justmessage $formattedTime';
            yield Text(
              displayMessage,
              style: TextStyle(color: Colors.grey),
            );
          } else {
            yield Text(
              'ยังไม่มีข้อความสนทนา',
              style: TextStyle(color: Colors.grey),
            );
          }
        }
      }
    } catch (e) {
      print('Error streaming last message: $e');
      yield Text(
        'Error streaming last message',
        style: TextStyle(color: Colors.grey),
      );
    }
  }

  Widget buildLastMessageWidget(String friendUid) {
    return StreamBuilder(
      stream: streamLastMessageAndDisplay(friendUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return snapshot.data as Widget;
      },
    );
  }

  void main() async {
    runApp(MaterialApp(
      home: FriendList(),
    ));
  }
}
