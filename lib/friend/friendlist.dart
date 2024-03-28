import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
                child: Icon(Icons.mail),
              ),
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
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No friend data found'));
            }

            Map<String, dynamic>? userData =
                snapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null || !userData.containsKey('friendList')) {
              return Center(child: Text('No friend data found'));
            }

            List<dynamic> friendList = userData['friendList'];

            if (friendList.isEmpty) {
              return Center(child: Text('No friends added yet'));
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

  Widget buildFriendItem(BuildContext context, String friendUid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
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
                Navigator.push(
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
                          flex: 8,
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container(); // Don't show the item if it doesn't match the search query
        }
      },
    );
  }

  Stream<Widget> streamLastMessageAndDisplay(String friendUid) async* {
    try {
      final collection = FirebaseFirestore.instance.collection('chats');

      // Stream for messages where current user is the receiver
      final stream1 = collection
          .where('receiverUid', isEqualTo: friendUid)
          .where('senderUid', isEqualTo: myUid)
          .orderBy('timestampserver', descending: true)
          .snapshots();

      // Stream for messages where current user is the sender
      final stream2 = collection
          .where('receiverUid', isEqualTo: myUid)
          .where('senderUid', isEqualTo: friendUid)
          .orderBy('timestampserver', descending: true)
          .snapshots();

      // Combine the streams
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
              'No messages yet',
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
