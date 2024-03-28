import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/friend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:triptourapp/tripmanage.dart';

class GroupScreenPage extends StatelessWidget {
  final String tripUid;

  GroupScreenPage({required this.tripUid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(tripUid: tripUid),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String tripUid;
  final timestampserver = FieldValue.serverTimestamp();

  ChatScreen({required this.tripUid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> fetchMessages() async {
    try {
      yourUserData = (await getUserData(getCurrentUserUid())) ?? {};

      if (yourUserData.isNotEmpty) {
        setState(() {});
      }
      // Fetch messages from the Firestore collection where the current user is either sender or receiver
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('groupmessages')
              .where('tripChatUid', isEqualTo: widget.tripUid)
              .where('senderUid', isEqualTo: getCurrentUserUid())
              .orderBy('timestampserver')
              .get();
      print('Fetched messages: ${querySnapshot.docs.length}');
      querySnapshot.docs.forEach((doc) {
        print('Message: ${doc.data()}');
      });
      List<Map<String, dynamic>> sentMessages = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final dynamic nickname = data['nickname'];
        final dynamic message = data['message'];
        final dynamic profileImageUrl = data['profileImageUrl'];
        final dynamic timestamp = data['timestampserver'];

        // Check if 'message' is a string
        if (message is String) {
          return {
            'user': 'You',
            'message': message,
            'timestamp': timestamp,
            'nickname': nickname,
            'profileImageUrl': profileImageUrl
          };
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
          .collection('groupmessages')
          .where('senderUid', isNotEqualTo: getCurrentUserUid())
          .where('tripChatUid', isEqualTo: widget.tripUid)
          .get();

      List<Map<String, dynamic>> receivedMessages =
          querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final dynamic nickname = data['nickname'];
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];
        final dynamic profileImageUrl = data['profileImageUrl'];
        // Check if 'message' is a string
        if (message is String) {
          return {
            'user': 'Friend',
            'message': message,
            'timestamp': timestamp,
            'nickname': nickname,
            'profileImageUrl': profileImageUrl
          };
        } else {
          // Handle the case where 'message' is not a string
          print('Warning: Message is not a string');
          return {
            'user': 'Friend',
            'message': 'Invalid message',
            'timestamp': timestamp,
            'nickname': nickname,
            'profileImageUrl': profileImageUrl
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
  }

  void removeMyfromFriendTrip(String friendUid) async {
    try {
      // 1. Remove the friendUid from the friendList of the current user
      await FirebaseFirestore.instance.collection('users').doc(myUid).update({
        'friendList': FieldValue.arrayRemove([friendUid]),
      });

      // 2. Fetch all trips where the friendUid is the trip creator
      QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('tripCreate', isEqualTo: friendUid)
          .get();

      // 3. Loop through each trip and remove the current user from tripJoin if exists
      tripsSnapshot.docs.forEach((tripDoc) async {
        String tripId = tripDoc.id;
        DocumentSnapshot tripDataSnapshot = tripDoc as DocumentSnapshot;
        List<dynamic> tripJoinList = tripDataSnapshot['tripJoin'];

        if (tripJoinList.contains(myUid)) {
          tripJoinList.remove(myUid);
          await FirebaseFirestore.instance
              .collection('trips')
              .doc(tripId)
              .update({'tripJoin': tripJoinList});
        }
      });

      // Log success or perform any other actions
      print('Friend removed successfully');
    } catch (error) {
      // Handle errors (e.g., Firestore errors, network errors, etc.)
      print('Error removing friend: $error');
    }
  }

  void removeFriendfromMyTrip(String friendUid) async {
    try {
      // 1. Remove the friendUid from the friendList of the current user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .update({
        'friendList': FieldValue.arrayRemove([myUid]),
      });

      // 2. Fetch all trips where the friendUid is the trip creator
      QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('tripCreate', isEqualTo: myUid)
          .get();

      // 3. Loop through each trip and remove the current user from tripJoin if exists
      tripsSnapshot.docs.forEach((tripDoc) async {
        String tripId = tripDoc.id;
        DocumentSnapshot tripDataSnapshot = tripDoc as DocumentSnapshot;
        List<dynamic> tripJoinList = tripDataSnapshot['tripJoin'];

        if (tripJoinList.contains(friendUid)) {
          tripJoinList.remove(friendUid);
          await FirebaseFirestore.instance
              .collection('trips')
              .doc(tripId)
              .update({'tripJoin': tripJoinList});
        }
      });

      // Log success or perform any other actions
      print('Friend removed successfully');
    } catch (error) {
      // Handle errors (e.g., Firestore errors, network errors, etc.)
      print('Error removing friend: $error');
    }
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream() {
    String currentUserUid = getCurrentUserUid();
    String friendUid = widget.tripUid;

    return FirebaseFirestore.instance
        .collection('groupmessages')
        .where('tripChatUid', isEqualTo: friendUid)
        .where('senderUid', isNotEqualTo: currentUserUid)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> sentMessages = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final dynamic senderUid = data['senderUid'];
        final dynamic nickname = data['nickname'];
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];
        final dynamic profileImageUrl = data['profileImageUrl'];
        // Check if 'message' is a string
        if (message is String) {
          return {
            'user': 'Friend',
            'message': message,
            'timestamp': timestamp,
            'nickname': nickname,
            'profileImageUrl': profileImageUrl
          };
        } else {
          // Handle the case where 'message' is not a string
          print('Warning: Message is not a string');
          return {
            'user': 'Friend',
            'message': 'Invalid message',
            'timestamp': timestamp,
            'nickname': nickname,
            'profileImageUrl': profileImageUrl
          };
        }
      }).toList();

      // Fetch messages where the current user is the receiver
      QuerySnapshot<Map<String, dynamic>> receivedQuerySnapshot =
          await FirebaseFirestore.instance
              .collection('groupmessages')
              .where('tripChatUid', isEqualTo: friendUid)
              .where('senderUid', isEqualTo: currentUserUid)
              .orderBy('timestampserver')
              .get();

      List<Map<String, dynamic>> receivedMessages =
          receivedQuerySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final dynamic message = data['message'];
        final dynamic nickname = data['nickname'];
        final dynamic timestamp = data['timestampserver'];
        final dynamic profileImageUrl = data['profileImageUrl'];

        // Check if 'message' is a string
        if (message is String) {
          return {
            'user': 'You',
            'message': message,
            'timestamp': timestamp,
            'nickname': nickname,
            'profileImageUrl': profileImageUrl
          };
        } else {
          // Handle the case where 'message' is not a string
          print('Warning: Message is not a string');
          return {
            'user': 'You',
            'message': 'Invalid message',
            'timestamp': timestamp,
            'nickname': nickname,
            'profileImageUrl': profileImageUrl
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
  String? tripname;
  Map<String, dynamic>? friendData;

  @override
  void initState() {
    super.initState();

    // Fetch and load messages when the screen is initially opened
    fetchMessages();
    getMessagesStream();
    getFriendData(widget.tripUid).then((data) {
      setState(() {
        friendData = data;
      });
    });
    FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripUid)
        .get()
        .then((tripSnapshot) {
      setState(() {
        tripname = tripSnapshot['tripName'];
      });
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0.0, // Scroll to the top
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      String currentUserUid = getCurrentUserUid();
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      return snapshot.data(); // Return user data
    } catch (e) {
      print("Error fetching current user data: $e");
      return null;
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
      final friendUid = widget.tripUid;

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0.0, // Scroll to the top
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
      Map<String, dynamic>? currentUserData = await getCurrentUserData();

      if (currentUserData != null) {
        String profileImageUrl = currentUserData['profileImageUrl'];
        String nickname = currentUserData['nickname'];
        if (messageText.length > 20) {
          // Split message into chunks of maximum 20 characters
          List<String> chunks = [];
          for (int i = 0; i < messageText.length; i += 20) {
            chunks.add(messageText.substring(
                i, i + 20 < messageText.length ? i + 20 : messageText.length));
          }
          // Join chunks with newline character
          String formattedMessage = chunks.join('\n');

          await FirebaseFirestore.instance.collection('groupmessages').add({
            'senderUid': currentUserUid,
            'tripChatUid': friendUid,
            'profileImageUrl': profileImageUrl,
            'nickname': nickname,
            'message': formattedMessage,
            'timestampserver': FieldValue.serverTimestamp(),
          });
        } else {
          await FirebaseFirestore.instance.collection('groupmessages').add({
            'senderUid': currentUserUid,
            'tripChatUid': friendUid,
            'profileImageUrl': profileImageUrl,
            'nickname': nickname,
            'message': messageText,
            'timestampserver': FieldValue.serverTimestamp(),
          });
        }
      }
      // After sending the message, fetch updated messages
      fetchMessages();
    }
  }

  void deleteChats(String currentUserUid, String friendUid) async {
    try {
      // Delete chats where the current user is the sender
      await FirebaseFirestore.instance
          .collection('chats')
          .where('senderUid', isEqualTo: currentUserUid)
          .where('receiverUid', isEqualTo: friendUid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // Delete chats where the current user is the receiver
      await FirebaseFirestore.instance
          .collection('chats')
          .where('receiverUid', isEqualTo: currentUserUid)
          .where('senderUid', isEqualTo: friendUid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      print('Chats deleted successfully');
    } catch (e) {
      print('Error deleting chats: $e');
    }
  }

  Future<void> deleteChatHistory(String senderUid, String receiverUid) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .where('senderUid', isEqualTo: senderUid)
          .where('receiverUid', isEqualTo: receiverUid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    } catch (e) {
      print('Error deleting chat history: $e');
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
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => scrollToBottom());
                  // Add this line

                  List<Map<String, dynamic>> messages = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - index - 1];
                      final user = message['user'] ?? '';
                      final messageText = message['message'] ?? '';
                      final isCurrentUser = user == 'You';
                      final messageTimestamp = message[
                          'timestamp']; // เก็บ timestampserver จากข้อมูลข้อความ
                      final timestamp = messageTimestamp != null
                          ? (messageTimestamp as Timestamp).toDate()
                          : null; // แปลง timestampserver เป็น DateTime
                      final formattedTime = timestamp != null
                          ? DateFormat('HH:mm').format(timestamp)
                          : ''; // แปลง DateTime เป็นรูปแบบของเวลาที่ต้องการ
                      final userData =
                          isCurrentUser ? yourUserData : friendUserData;
                      final nickname = message['nickname'] ?? '';
                      final profileImageUrl = message['profileImageUrl'] ?? '';
                      return ListTile(
                        title: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 0.0),
                          child: Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isCurrentUser && profileImageUrl.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 28.0),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(profileImageUrl),
                                  ),
                                ),
                              SizedBox(width: 8.0),
                              Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isCurrentUser && nickname.isNotEmpty)
                                    Text(
                                      nickname,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 117, 114, 114),
                                          fontSize: 15),
                                    ),
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

                                  SizedBox(
                                      height:
                                          4), // Add some space between message and timestamp
                                  Text(
                                    formattedTime, // Display formatted timestamp
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
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
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Handle add icon tap
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Handle camera icon tap
                                  Navigator.pop(context);
                                  // Add your camera logic here
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.camera_alt, size: 25.0),
                                    Text('ถ่ายรูป',
                                        style: GoogleFonts.ibmPlexSansThai()),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 0.1,
                              ),
                              InkWell(
                                onTap: () {
                                  // Handle camera icon tap
                                  Navigator.pop(context);
                                  // Add your camera logic here
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.image, size: 25.0),
                                    Text('รูปภาพ',
                                        style: GoogleFonts.ibmPlexSansThai()),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Handle camera icon tap
                                  Navigator.pop(context);
                                  // Add your camera logic here
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.place, size: 25.0),
                                    Text('มารค์จุดนัดพบ',
                                        style: GoogleFonts.ibmPlexSansThai()),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Handle camera icon tap
                                  Navigator.pop(context);
                                  // Add your camera logic here
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.star, size: 25.0),
                                    Text('แนะนำสิ่งน่าสนใจ',
                                        style: GoogleFonts.ibmPlexSansThai()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'พิมข้อความ',
                          border: InputBorder.none, // Remove the border
                        ),
                        maxLines: null, // Allow multiline input
                        textInputAction: TextInputAction.newline,
                      ),
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
        title: Text(tripname ?? 'Loading...'),
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TripmanagePage(tripUid: widget.tripUid)),
            );
          },
        ),
      ),
    );
  }
}
//  void _sendMessage() async {
//     final messageText = _messageController.text;
//     if (messageText.isNotEmpty) {
//       _messageController.clear();

//       final currentUserUid = getCurrentUserUid();
//       final friendUid = widget.friendUid;

//       WidgetsBinding.instance!.addPostFrameCallback((_) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       });

//       try {
//         await FirebaseFirestore.instance.collection('messages').add({
//           'senderUid': currentUserUid,
//           'receiverUid': friendUid,
//           'message': messageText,
//           'timestampserver': FieldValue.serverTimestamp(),
//         });

//         // No need to setState for messages as StreamBuilder takes care of it
//       } catch (e) {
//         print('Error sending message: $e');
//       }
//     }
//   }
