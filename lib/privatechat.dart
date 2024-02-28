import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/friend.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreenPage extends StatelessWidget {
  final String friendUid;

  ChatScreenPage({required this.friendUid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(friendUid: friendUid),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String friendUid;
  final timestampserver = FieldValue.serverTimestamp();

  ChatScreen({required this.friendUid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> fetchMessages() async {
    try {
      yourUserData = (await getUserData(getCurrentUserUid())) ?? {};
      friendUserData = (await getUserData(widget.friendUid)) ?? {};
      if (yourUserData.isNotEmpty && friendUserData.isNotEmpty) {
        setState(() {});
      }
      // Fetch messages from the Firestore collection where the current user is either sender or receiver
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('messages')
              .where('senderUid', isEqualTo: getCurrentUserUid())
              .where('receiverUid', isEqualTo: widget.friendUid)
              .orderBy('timestampserver')
              .get();
      print('Fetched messages: ${querySnapshot.docs.length}');
      querySnapshot.docs.forEach((doc) {
        print('Message: ${doc.data()}');
      });
      List<Map<String, dynamic>> sentMessages = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];

        // Check if 'message' is a string
        if (message is String) {
          return {'user': 'You', 'message': message, 'timestamp': timestamp};
        } else {
          // Handle the case where 'message' is not a string
          print('Warning: Message is not a string');
          return {
            'user': 'You',
            'message': 'Invalid message',
            'timestamp': timestamp
          };
        }
      }).toList();

      // Fetch messages where the current user is the receiver
      querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('receiverUid', isEqualTo: getCurrentUserUid())
          .where('senderUid', isEqualTo: widget.friendUid)
          .get();

      List<Map<String, dynamic>> receivedMessages =
          querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];

        // Check if 'message' is a string
        if (message is String) {
          return {'user': 'Friend', 'message': message, 'timestamp': timestamp};
        } else {
          // Handle the case where 'message' is not a string
          print('Warning: Message is not a string');
          return {
            'user': 'Friend',
            'message': 'Invalid message',
            'timestamp': timestamp
          };
        }
      }).toList();

      // Combine sent and received messages
      List<Map<String, dynamic>> allMessages = [
        ...sentMessages,
        ...receivedMessages
      ];

      // Sort messages by timestamp
      allMessages.sort((a, b) {
        final Timestamp timestampA = a['timestamp'];
        final Timestamp timestampB = b['timestamp'];
        return timestampA.compareTo(timestampB);
      });

      setState(() {
        _messages = allMessages;
      });
    } catch (e) {
      print('Error fetching messages: $e');
    }
    scrollToBottom();
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream() {
    String currentUserUid = getCurrentUserUid();
    String friendUid = widget.friendUid;

    return FirebaseFirestore.instance
        .collection('messages')
        .where('receiverUid', isEqualTo: currentUserUid)
        .where('senderUid', isEqualTo: friendUid)
        .orderBy('timestampserver')
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> sentMessages = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];

        // Check if 'message' is a string
        if (message is String) {
          return {'user': 'Friend', 'message': message, 'timestamp': timestamp};
        } else {
          // Handle the case where 'message' is not a string
          print('Warning: Message is not a string');
          return {
            'user': 'Friend',
            'message': 'Invalid message',
            'timestamp': timestamp
          };
        }
      }).toList();

      // Fetch messages where the current user is the receiver
      QuerySnapshot<Map<String, dynamic>> receivedQuerySnapshot =
          await FirebaseFirestore.instance
              .collection('messages')
              .where('receiverUid', isEqualTo: friendUid)
              .where('senderUid', isEqualTo: currentUserUid)
              .orderBy('timestampserver')
              .get();

      List<Map<String, dynamic>> receivedMessages =
          receivedQuerySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];

        // Check if 'message' is a string
        if (message is String) {
          return {'user': 'You', 'message': message, 'timestamp': timestamp};
        } else {
          // Handle the case where 'message' is not a string
          print('Warning: Message is not a string');
          return {
            'user': 'You',
            'message': 'Invalid message',
            'timestamp': timestamp
          };
        }
      }).toList();

      // Combine sent and received messages
      List<Map<String, dynamic>> allMessages = [
        ...sentMessages,
        ...receivedMessages
      ];

      // Sort messages by timestamp
      allMessages.sort((a, b) {
        final Timestamp timestampA = a['timestamp'];
        final Timestamp timestampB = b['timestamp'];
        return timestampA.compareTo(timestampB);
      });

      return allMessages;
    });
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return snapshot.data() as Map<String, dynamic>?; // Return user data
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  late Map<String, dynamic> yourUserData = {};
  late Map<String, dynamic> friendUserData = {};
  Map<String, dynamic>? friendData;

  @override
  void initState() {
    super.initState();

    // Fetch and load messages when the screen is initially opened
    fetchMessages();
    getMessagesStream();
    getFriendData(widget.friendUid).then((data) {
      setState(() {
        friendData = data;
      });
    });

    // Scroll to the bottom after the frame has been painted
  }

  void scrollToBottom() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<Map<String, dynamic>?> getFriendData(String friendUid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .get();
      return snapshot.data() as Map<String, dynamic>?; // Return friend data
    } catch (e) {
      print("Error fetching friend data: $e");
      return null;
    }
  }

  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      // Handle the case where the user is not authenticated
      return '';
    }
  }

  Future<void> removeFriendFromCurrentUser(
      String currentUserUid, String friendUid) async {
    try {
      // Reference to the current user's document
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserUid);

      // Remove friendUid from the friendList array
      await currentUserRef.update({
        'friendList': FieldValue.arrayRemove([friendUid]),
      });

      print('Friend removed successfully');
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  Future<void> removeCurrentUserFromFriend(
      String currentUserUid, String friendUid) async {
    try {
      // Reference to the friend's document
      DocumentReference friendRef =
          FirebaseFirestore.instance.collection('users').doc(friendUid);

      // Remove currentUserUid from the friend's friendList array
      await friendRef.update({
        'friendList': FieldValue.arrayRemove([currentUserUid]),
      });

      print('Current user removed from friend successfully');
    } catch (e) {
      print('Error removing current user from friend: $e');
    }
  }

  void _sendMessage() async {
    final messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      _messageController.clear();

      final currentUserUid = getCurrentUserUid();
      final friendUid = widget.friendUid;

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      try {
        await FirebaseFirestore.instance.collection('messages').add({
          'senderUid': currentUserUid,
          'receiverUid': friendUid,
          'message': messageText,
          'timestampserver': FieldValue.serverTimestamp(),
        });

        // No need to setState for messages as StreamBuilder takes care of it
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> messages = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final user = message['user'] ?? '';
                      final messageText = message['message'] ?? '';
                      final isCurrentUser = user == 'You';

                      final userData =
                          isCurrentUser ? yourUserData : friendUserData;
                      final profileImageUrl =
                          userData?['profileImageUrl'] ?? '';

                      return ListTile(
                        title: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 0.0),
                          child: Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isCurrentUser)
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(profileImageUrl),
                                ),
                              SizedBox(width: 8.0),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.blue
                                      : Colors.green,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  messageText,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'พิมข้อความ',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: friendData != null
            ? Text('${friendData!['firstName']} ${friendData!['lastName']}')
            : Text('Loading...'),
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Friend()),
            );
          },
        ),
        actions: [
          IconButton(
            color: Colors.black,
            icon: Icon(Icons.menu),
            onPressed: () async {
              final result = await showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  100,
                  100,
                  0,
                  0,
                ),
                items: [
                  PopupMenuItem(
                    child: Text(
                      'ลบเพื่อน',
                      style: GoogleFonts.ibmPlexSansThai(),
                    ),
                    value: 'deletefriend',
                  ),
                ],
              );
              if (result != null) {
                switch (result) {
                  case 'deletefriend':
                    String currentUserUid = getCurrentUserUid();
                    removeFriendFromCurrentUser(
                        currentUserUid, widget.friendUid);
                    removeCurrentUserFromFriend(
                        currentUserUid, widget.friendUid);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Friend()),
                    );
                    break;
                }
              }
            },
          )
        ],
      ),
    );
  }
}
