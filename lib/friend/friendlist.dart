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
  late List<dynamic> friendList = [];

  @override
  void initState() {
    super.initState();
    fetchFriendList();
  }

  void fetchFriendList() async {
    try {
      DocumentSnapshot userDataSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(myUid).get();

      if (userDataSnapshot.exists) {
        Map<String, dynamic>? userData =
            userDataSnapshot.data() as Map<String, dynamic>?;

        setState(() {
          friendList = userData?['friendList'] ?? [];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
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
                child: Icon(Icons.mail),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        if (friendList.isNotEmpty)
          for (String friendUid in friendList)
            buildTripItem(context, friendUid),
      ],
    );
  }

  Widget buildTripItem(BuildContext context, String friendUid) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(friendUid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Icon(Icons.error);
        }
        Map<String, dynamic>? friendData =
            snapshot.data?.data() as Map<String, dynamic>?;

        String fullName = '';
        bool matchesSearch = false;

        if (friendData != null) {
          fullName = '${friendData['firstName']} ${friendData['lastName']}'
              .toLowerCase();
          matchesSearch = fullName.contains(_searchQuery);
        }

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
                                friendData?['profileImageUrl'] ??
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
                                  '${friendData?['firstName']} ${friendData?['lastName']}',
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

  Future<Widget> fetchLastMessageAndDisplay(String friendUid) async {
    try {
      // Fetch the last message where current user is the receiver
      var querySnapshot1 = await FirebaseFirestore.instance
          .collection('chats')
          .where('receiverUid', isEqualTo: myUid)
          .where('senderUid', isEqualTo: friendUid)
          .orderBy('timestampserver', descending: true)
          .limit(1)
          .get();

      // Fetch the last message where current user is the sender
      var querySnapshot2 = await FirebaseFirestore.instance
          .collection('chats')
          .where('receiverUid', isEqualTo: friendUid)
          .where('senderUid', isEqualTo: myUid)
          .orderBy('timestampserver', descending: true)
          .limit(1)
          .get();

      // Compare timestamps and select the most recent message
      Map<String, dynamic>? lastMessage;
      if (querySnapshot1.docs.isNotEmpty && querySnapshot2.docs.isNotEmpty) {
        final message1 = querySnapshot1.docs[0].data();
        final message2 = querySnapshot2.docs[0].data();
        lastMessage =
            message1['timestampserver'].compareTo(message2['timestampserver']) >
                    0
                ? message1
                : message2;
      } else if (querySnapshot1.docs.isNotEmpty) {
        lastMessage = querySnapshot1.docs[0].data();
      } else if (querySnapshot2.docs.isNotEmpty) {
        lastMessage = querySnapshot2.docs[0].data();
      }

      if (lastMessage != null) {
        String messageText = lastMessage['lastMessage'] ?? '';
        String justmessage = messageText.length > 20
            ? messageText.substring(0, 20)
            : messageText;
        if (justmessage.length > 17) {
          justmessage += '...';
        }

        String senderUid = lastMessage['senderUid'];
        Timestamp timestamp = lastMessage['timestampserver'];
        String formattedTime = DateFormat('HH:mm').format(timestamp.toDate());

        String displayMessage = senderUid == myUid
            ? 'You: $justmessage $formattedTime'
            : 'ชื่อเพื่อน: $justmessage $formattedTime'; // Adjust to include friend's name
        // Fetch friend's name if needed
        if (senderUid != myUid) {
          DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(friendUid)
              .get();
          Map<String, dynamic> friendData =
              friendSnapshot.data() as Map<String, dynamic>;
          String friendName =
              '${friendData['firstName']} ${friendData['lastName']}';
          displayMessage = '$friendName: $justmessage $formattedTime';
        }

        return Text(
          displayMessage,
          style: TextStyle(color: Colors.grey),
        );
      } else {
        return Text(
          'No messages yet',
          style: TextStyle(color: Colors.grey),
        );
      }
    } catch (e) {
      print('Error fetching last message: $e');
      return Text(
        'Error fetching last message',
        style: TextStyle(color: Colors.grey),
      );
    }
  }

  Widget buildLastMessageWidget(String friendUid) {
    return FutureBuilder(
      future: fetchLastMessageAndDisplay(friendUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return snapshot.data as Widget;
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: FriendList(),
  ));
}
