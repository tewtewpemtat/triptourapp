import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/friend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
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
        Map<String, dynamic> data = doc.data();
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];

        if (message is String) {
          return {'user': 'You', 'message': message, 'timestamp': timestamp};
        } else {
          print('Warning: Message is not a string');
          return {
            'user': 'You',
            'message': 'Invalid message',
            'timestamp': timestamp
          };
        }
      }).toList();

      querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('receiverUid', isEqualTo: getCurrentUserUid())
          .where('senderUid', isEqualTo: widget.friendUid)
          .get();

      List<Map<String, dynamic>> receivedMessages =
          querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];

        if (message is String) {
          return {'user': 'Friend', 'message': message, 'timestamp': timestamp};
        } else {
          print('Warning: Message is not a string');
          return {
            'user': 'Friend',
            'message': 'Invalid message',
            'timestamp': timestamp
          };
        }
      }).toList();

      List<Map<String, dynamic>> allMessages = [
        ...sentMessages,
        ...receivedMessages
      ];

      allMessages.sort((a, b) {
        final Timestamp timestampA = a['timestamp'];
        final Timestamp timestampB = b['timestamp'];
        return timestampA.compareTo(timestampB);
      });

      setState(() {});
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  void removeMyfromFriendTrip(String friendUid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(myUid).update({
        'friendList': FieldValue.arrayRemove([friendUid]),
      });

      QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('tripCreate', isEqualTo: friendUid)
          .get();

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

      print('Friend removed successfully');
    } catch (error) {
      print('Error removing friend: $error');
    }
  }

  void removeFriendfromMyTrip(String friendUid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .update({
        'friendList': FieldValue.arrayRemove([myUid]),
      });

      QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('tripCreate', isEqualTo: myUid)
          .get();

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

      print('Friend removed successfully');
    } catch (error) {
      print('Error removing friend: $error');
    }
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
        Map<String, dynamic> data = doc.data();
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];

        if (message is String) {
          return {'user': 'Friend', 'message': message, 'timestamp': timestamp};
        } else {
          print('Warning: Message is not a string');
          return {
            'user': 'Friend',
            'message': 'Invalid message',
            'timestamp': timestamp
          };
        }
      }).toList();

      QuerySnapshot<Map<String, dynamic>> receivedQuerySnapshot =
          await FirebaseFirestore.instance
              .collection('messages')
              .where('receiverUid', isEqualTo: friendUid)
              .where('senderUid', isEqualTo: currentUserUid)
              .orderBy('timestampserver')
              .get();

      List<Map<String, dynamic>> receivedMessages =
          receivedQuerySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        final dynamic message = data['message'];
        final dynamic timestamp = data['timestampserver'];

        if (message is String) {
          return {'user': 'You', 'message': message, 'timestamp': timestamp};
        } else {
          print('Warning: Message is not a string');
          return {
            'user': 'You',
            'message': 'Invalid message',
            'timestamp': timestamp
          };
        }
      }).toList();

      List<Map<String, dynamic>> allMessages = [
        ...sentMessages,
        ...receivedMessages
      ];

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
      return snapshot.data() as Map<String, dynamic>?;
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

    fetchMessages();
    getMessagesStream();
    getFriendData(widget.friendUid).then((data) {
      setState(() {
        friendData = data;
      });
    });
  }

  Future<Map<String, dynamic>?> getFriendData(String friendUid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .get();
      return snapshot.data() as Map<String, dynamic>?;
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
      return '';
    }
  }

  Future<void> removeFriendFromCurrentUser(
      String currentUserUid, String friendUid) async {
    try {
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserUid);

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
      DocumentReference friendRef =
          FirebaseFirestore.instance.collection('users').doc(friendUid);

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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
      final chatSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('senderUid', isEqualTo: currentUserUid)
          .where('receiverUid', isEqualTo: friendUid)
          .get();
      if (chatSnapshot.docs.isNotEmpty) {
        final chatDocId = chatSnapshot.docs.first.id;
        try {
          if (messageText.length > 20) {
            List<String> chunks = [];
            for (int i = 0; i < messageText.length; i += 20) {
              chunks.add(messageText.substring(i,
                  i + 20 < messageText.length ? i + 20 : messageText.length));
            }
            String formattedMessage = chunks.join('\n');

            await FirebaseFirestore.instance.collection('messages').add({
              'senderUid': currentUserUid,
              'receiverUid': friendUid,
              'message': formattedMessage,
              'timestampserver': FieldValue.serverTimestamp(),
              'status': 'Unread',
            });
            await FirebaseFirestore.instance
                .collection('chats')
                .doc(chatDocId)
                .update({
              'lastMessage': messageText,
              'senderUid': currentUserUid,
              'receiverUid': friendUid,
              'timestampserver': FieldValue.serverTimestamp(),
            });
          } else {
            await FirebaseFirestore.instance.collection('messages').add({
              'senderUid': currentUserUid,
              'receiverUid': friendUid,
              'message': messageText,
              'timestampserver': FieldValue.serverTimestamp(),
              'status': 'Unread',
            });
            await FirebaseFirestore.instance
                .collection('chats')
                .doc(chatDocId)
                .update({
              'lastMessage': messageText,
              'senderUid': currentUserUid,
              'receiverUid': friendUid,
              'timestampserver': FieldValue.serverTimestamp(),
            });
          }
          fetchMessages();
        } catch (e) {
          print('Error sending message: $e');
        }
      } else {
        try {
          if (messageText.length > 20) {
            List<String> chunks = [];
            for (int i = 0; i < messageText.length; i += 20) {
              chunks.add(messageText.substring(i,
                  i + 20 < messageText.length ? i + 20 : messageText.length));
            }
            String formattedMessage = chunks.join('\n');

            await FirebaseFirestore.instance.collection('messages').add({
              'senderUid': currentUserUid,
              'receiverUid': friendUid,
              'message': formattedMessage,
              'timestampserver': FieldValue.serverTimestamp(),
            });
            await FirebaseFirestore.instance.collection('chats').add({
              'lastMessage': messageText,
              'senderUid': currentUserUid,
              'receiverUid': friendUid,
              'timestampserver': FieldValue.serverTimestamp(),
            });
          } else {
            await FirebaseFirestore.instance.collection('messages').add({
              'senderUid': currentUserUid,
              'receiverUid': friendUid,
              'message': messageText,
              'timestampserver': FieldValue.serverTimestamp(),
            });
            await FirebaseFirestore.instance.collection('chats').add({
              'lastMessage': messageText,
              'senderUid': currentUserUid,
              'receiverUid': friendUid,
              'timestampserver': FieldValue.serverTimestamp(),
            });
          }
          fetchMessages();
        } catch (e) {
          print('Error sending message: $e');
        }
      }
    }
  }

  void deleteChats(String currentUserUid, String friendUid) async {
    try {
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

  String generateRandomNumber() {
    Random random = Random();
    int randomNumber = random.nextInt(999999999 - 100000000) + 100000000;
    return randomNumber.toString();
  }

  Future<void> _pickImage(String uid) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Map<String, dynamic>? userData = await getUserData(uid);
      if (userData != null) {
        String? nickname = userData['nickname'];
        String? profileImageUrl = userData['profileImageUrl'];
        _showSendDialog(
            pickedFile.path, nickname ?? '', profileImageUrl ?? '', 'รูปภาพ');
      } else {}
    }
  }

  Future<void> _pickCamera(String uid) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      Map<String, dynamic>? userData = await getUserData(uid);
      if (userData != null) {
        String? nickname = userData['nickname'];
        String? profileImageUrl = userData['profileImageUrl'];
        _showSendDialog(
            pickedFile.path, nickname ?? '', profileImageUrl ?? '', 'กล้อง');
      } else {}
    }
  }

  Future<Size> getImageSize(String imageUrl) async {
    Completer<Size> completer = Completer();
    Image image = Image.network(
      imageUrl,
      width: 300,
      height: 500,
    );
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );
    return completer.future;
  }

  Future<void> showPic(String img) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  FutureBuilder<Size>(
                    future: getImageSize(img),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Failed to load image');
                      }
                      final Size imageSize = snapshot.data!;
                      double width = imageSize.width;
                      double height = imageSize.height;

                      if (width > 300 || height > 500) {
                        double ratio = width / height;
                        if (ratio > 1) {
                          width = 300;
                          height = width / ratio;
                        } else {
                          height = 500;
                          width = height * ratio;
                        }
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          img,
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Text('Failed to load image');
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSendDialog(String img, String nickname,
      String profileImageUrl, String option) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.file(File(img)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ส่ง'),
              onPressed: () {
                _uploadImage(img, nickname, profileImageUrl, option);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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

  Future<void> _uploadImage(String img, String nickname, String profileImageUrl,
      String option) async {
    try {
      String message = 'uploadpic';
      final randomImg = generateRandomNumber();
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      String storagePath = 'message/$uid/$randomImg.jpg';

      Reference storageReference = FirebaseStorage.instance.ref(storagePath);

      File imgsave = File(img);
      await storageReference.putFile(imgsave);

      final String imageUrl = await storageReference.getDownloadURL();

      if (option == "กล้อง") {
        message = 'ahGOke969S8G9hjjAODKsowW@@${imageUrl}';
      }
      if (option == "รูปภาพ") {
        message = 'W5s9we6W8CF895w9f4sjyfr@@${imageUrl}';
      }

      final MessageCollection =
          FirebaseFirestore.instance.collection('messages');
      await MessageCollection.add({
        'message': message,
        'receiverUid': widget.friendUid,
        'senderUid': uid,
        'timestampserver': FieldValue.serverTimestamp(),
        'status': 'Unread',
      });
      fetchMessages();
    } catch (e) {
      print('Error uploading image: $e');
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
                    reverse: true,
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - index - 1];
                      final user = message['user'] ?? '';
                      final messageText = message['message'] ?? '';
                      final isCurrentUser = user == 'You';
                      final messageTimestamp = message['timestamp'];
                      final timestamp = messageTimestamp != null
                          ? (messageTimestamp as Timestamp).toDate()
                          : null;
                      final formattedTime = timestamp != null
                          ? DateFormat('HH:mm').format(timestamp)
                          : '';
                      final userData =
                          isCurrentUser ? yourUserData : friendUserData;
                      final profileImageUrl = userData['profileImageUrl'] ?? '';
                      var urlpic = '';
                      bool isSpecialMessage3 =
                          messageText.contains("W5s9we6W8CF895w9f4sjyfr");
                      bool isSpecialMessage4 =
                          messageText.contains("ahGOke969S8G9hjjAODKsowW");
                      if (isSpecialMessage3 || isSpecialMessage4) {
                        urlpic = messageText.split('@@')[1];
                      }
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
                                  Container(
                                    padding:
                                        isSpecialMessage3 || isSpecialMessage4
                                            ? EdgeInsets.all(0.0)
                                            : EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? Colors.blue
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: isSpecialMessage3 ||
                                            isSpecialMessage4
                                        ? Container(
                                            child: GestureDetector(
                                              onTap: () {
                                                showPic(urlpic);
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  urlpic,
                                                  width: 200,
                                                  height: 300,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Text(
                                                        'Failed to load image');
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            messageText,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    formattedTime,
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
                                  Navigator.pop(context);
                                  _pickCamera(myUid ?? '');
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
                                  Navigator.pop(context);
                                  _pickImage(myUid ?? '');
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.image, size: 25.0),
                                    Text('รูปภาพ',
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
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'พิมข้อความ',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
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
            markMessagesAsRead(widget.friendUid);
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
                    String friendUid = widget.friendUid;
                    removeFriendfromMyTrip(friendUid);
                    removeMyfromFriendTrip(friendUid);
                    removeFriendFromCurrentUser(
                        currentUserUid, widget.friendUid);
                    removeCurrentUserFromFriend(
                        currentUserUid, widget.friendUid);
                    deleteChatHistory(currentUserUid, friendUid);
                    deleteChatHistory(friendUid, currentUserUid);
                    deleteChats(currentUserUid, friendUid);
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
