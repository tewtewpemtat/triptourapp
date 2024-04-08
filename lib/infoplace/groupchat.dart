import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:triptourapp/infoplace.dart';
import 'package:triptourapp/saveinterest/interest.dart';
import 'package:triptourapp/saveinterest/meetplace.dart';
import 'package:geolocator/geolocator.dart';
import 'package:triptourapp/tripmanage/maproute.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class GroupScreenPage extends StatelessWidget {
  final String tripUid;
  final String placeid;
  GroupScreenPage({required this.tripUid, required this.placeid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(tripUid: tripUid, placeid: placeid),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String tripUid;
  final String placeid;
  final timestampserver = FieldValue.serverTimestamp();

  ChatScreen({required this.tripUid, required this.placeid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String? placename;
  String? placepicUrl;
  String? placeid;

  String? placetripid;
  String? placeaddress;
  double userLatitude = 0.0; // พิกัดละติจูดปัจจุบันของผู้ใช้
  double userLongitude = 0.0; // พิกัดลองจิจูดปัจจุบันของผู้ใช้
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
    getUserLocation();
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

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    } catch (e) {
      print("Error getting user location: $e");
    }
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

  void _showSpecialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Special Message"),
          content: Text("Hi"),
          actions: <Widget>[],
        );
      },
    );
  }

  void getPlaceData(String postId, BuildContext context) async {
    try {
      // ค้นหา document ใน collection 'placemeet' โดยใช้ postId ที่ได้จากข้อความ
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('placemeet')
          .doc(postId)
          .get();

      // ถ้าพบ document
      if (snapshot.exists) {
        // เข้าถึงข้อมูลจาก snapshot
        String placename = snapshot['placename'];
        String placepicUrl = snapshot['placepicUrl'];
        String placeid = snapshot['placeid'];
        double placeLatitude = snapshot['placeLatitude'];
        double placeLongitude = snapshot['placeLongitude'];
        String placetripid = snapshot['placetripid'];
        String placeaddress = snapshot['placeaddress'];

        // แสดงข้อมูลในรูปแบบของ Dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                  child: Text('จุดนัดพบ',
                      style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 24, fontWeight: FontWeight.bold))),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          10.0), // กำหนด border radius ให้กับรูปภาพ
                      child: Image.network(
                        placepicUrl,
                        width: 150.0,
                        height: 150.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "ชื่อจุดนัดพบ:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "$placename",
                          ),
                          Divider(),
                          Text(
                            "รายละเอียด:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "$placeaddress",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('นำทางจุดนัดพบ'),
                  onPressed: () {
                    rounttomap(placeLatitude, placeLongitude, context);
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
      } else {
        // ถ้าไม่พบ document
        print('ไม่พบเอกสาร');
      }
    } catch (e) {
      // หากเกิดข้อผิดพลาดในการเรียกข้อมูล
      print('Error retrieving place data: $e');
    }
  }

  void rounttomap(double placeLatitude, double placeLongitude, context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          tripUid: widget.tripUid,
          placeid: widget.placeid,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          placeLatitude: placeLatitude, // ประกาศพารามิเตอร์ placelatitude
          placeLongitude: placeLongitude, // ประกาศพารามิเตอร์ placelongitude
        ),
      ),
    );
  }

  void getPlaceData2(String postId, BuildContext context) async {
    try {
      // ค้นหา document ใน collection 'placemeet' โดยใช้ postId ที่ได้จากข้อความ
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('interest')
          .doc(postId)
          .get();

      // ถ้าพบ document
      if (snapshot.exists) {
        // เข้าถึงข้อมูลจาก snapshot
        String placepicUrl = snapshot['placepicUrl'];
        String placeid = snapshot['placeid'];
        String placetripid = snapshot['placetripid'];
        double placeLatitude = snapshot['placeLatitude'];
        double placeLongitude = snapshot['placeLongitude'];
        String placeaddress = snapshot['placeaddress'];

        // แสดงข้อมูลในรูปแบบของ Dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                  child: Text('สิ่งน่าสนใจ',
                      style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 24, fontWeight: FontWeight.bold))),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          10.0), // กำหนด border radius ให้กับรูปภาพ
                      child: Image.network(
                        placepicUrl,
                        width: 150.0,
                        height: 150.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "รายละเอียดสิ่งน่าสนใจ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "$placeaddress",
                          ),
                          Divider(),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('นำทางไปยังสิ่งน่าสนใจ'),
                  onPressed: () {
                    rounttomap(placeLatitude, placeLongitude, context);
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
      } else {
        // ถ้าไม่พบ document
        print('ไม่พบเอกสาร');
      }
    } catch (e) {
      // หากเกิดข้อผิดพลาดในการเรียกข้อมูล
      print('Error retrieving place data: $e');
    }
  }

  void meetplace(BuildContext context) async {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MeetplacePage(tripUid: widget.tripUid!, placeid: widget.placeid),
        ),
      );
    } catch (e) {
      print('Error navigating to MeetplacePage: $e');
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
      } else {
        // Handle case where user data is not available
      }
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
      } else {
        // Handle case where user data is not available
      }
    }
  }

  Future<Size> getImageSize(String imageUrl) async {
    Completer<Size> completer = Completer();
    Image image = Image.network(
      imageUrl,
      width: 300, // Limit width to 300 for faster image loading
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
            Navigator.pop(
                context); // Navigate back when tapped outside the dialog
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

                      // Limit width and height to 300
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

  Future<void> _uploadImage(String img, String nickname, String profileImageUrl,
      String option) async {
    try {
      String message = 'uploadpic';
      final randomImg =
          generateRandomNumber(); // Generate a random 9-digit number
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      // กำหนด path ใน Firebase Storage
      String storagePath = 'message/$uid/$randomImg.jpg';

      // สร้าง Reference สำหรับอ้างถึง storagePath
      Reference storageReference = FirebaseStorage.instance.ref(storagePath);

      File imgsave = File(img);
      if (imgsave != null) {
        // อัปโหลดไฟล์รูปภาพ
        await storageReference.putFile(imgsave!);

        // ดึง URL ของรูปภาพที่อัปโหลด
        final String imageUrl = await storageReference.getDownloadURL();

        // ทำอะไรกับ imageUrl ต่อไป
        if (option == "กล้อง") {
          message = 'ahGOke969S8G9hjjAODKsowW@@${imageUrl}';
        }
        if (option == "รูปภาพ") {
          message = 'W5s9we6W8CF895w9f4sjyfr@@${imageUrl}';
        }

        // Update the user document with the image URL
        final MessageCollection =
            FirebaseFirestore.instance.collection('groupmessages');
        await MessageCollection.add({
          'message': message,
          'nickname': nickname,
          'profileImageUrl': profileImageUrl,
          'senderUid': uid,
          'timestampserver': FieldValue
              .serverTimestamp(), // Assuming you have a timestamp field
          'tripChatUid': widget.tripUid
        });
        fetchMessages();
      }
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
                      var urlpic = '';
                      final nickname = message['nickname'] ?? '';
                      final profileImageUrl = message['profileImageUrl'] ?? '';
                      bool isSpecialMessage =
                          messageText.contains("3w9dc126vc68a5a6xlTHFs");
                      bool isSpecialMessage2 =
                          messageText.contains("28sd829gDw8d6a8w4d8a6");
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
                            mainAxisAlignment:
                                (isSpecialMessage || isSpecialMessage2)
                                    ? MainAxisAlignment.center
                                    : isCurrentUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if ((!isSpecialMessage && !isSpecialMessage2) &&
                                  !isCurrentUser &&
                                  profileImageUrl.isNotEmpty)
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
                                  if ((!isSpecialMessage &&
                                          !isSpecialMessage2) &&
                                      !isCurrentUser &&
                                      nickname.isNotEmpty)
                                    Text(
                                      nickname,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 117, 114, 114),
                                          fontSize: 15),
                                    ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding:
                                          isSpecialMessage3 || isSpecialMessage4
                                              ? EdgeInsets.all(0.0)
                                              : EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: (isSpecialMessage ||
                                                isSpecialMessage2)
                                            ? Color.fromARGB(0, 127, 130, 134)
                                            : isCurrentUser
                                                ? Colors.blue
                                                : Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: isSpecialMessage
                                          ? Row(children: [
                                              Text(
                                                " $nickname ได้เพิ่มจุดนัดพบใหม่ ",
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 59, 57, 57)),
                                              ),
                                              Container(
                                                // กำหนดความสูงของ GestureDetector
                                                child: GestureDetector(
                                                  onTap: () {
                                                    String postId = messageText
                                                        .split('=')[1];
                                                    // แยก postId จากข้อความโดยใช้เครื่องหมาย '='
                                                    getPlaceData(
                                                        postId, context);
                                                  },
                                                  child: Text(
                                                    "ดูรายละเอียด ",
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 105, 107, 111),
                                                      decoration: TextDecoration
                                                          .underline, // เพิ่มเส้นใต้ที่นี่
                                                    ),
                                                  ), // วิดเจ็ตที่คุณต้องการวางภายใน GestureDetector
                                                ),
                                              )
                                            ])
                                          : isSpecialMessage2
                                              ? Row(children: [
                                                  Text(
                                                    " $nickname ได้เพิ่มสิ่งน่าสนใจใหม่ ",
                                                    style: TextStyle(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 59, 57, 57)),
                                                  ),
                                                  Container(
                                                    // กำหนดความสูงของ GestureDetector
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        String postId =
                                                            messageText
                                                                .split('=')[1];
                                                        // แยก postId จากข้อความโดยใช้เครื่องหมาย '='
                                                        getPlaceData2(
                                                            postId, context);
                                                      },
                                                      child: Text(
                                                        "ดูรายละเอียด ",
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              105,
                                                              107,
                                                              111),
                                                          decoration: TextDecoration
                                                              .underline, // เพิ่มเส้นใต้ที่นี่
                                                        ),
                                                      ), // วิดเจ็ตที่คุณต้องการวางภายใน GestureDetector
                                                    ),
                                                  )
                                                ])
                                              : isSpecialMessage3 ||
                                                      isSpecialMessage4
                                                  ? Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          showPic(urlpic);
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                            urlpic,
                                                            width: 200,
                                                            height: 300,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              );
                                                            },
                                                            errorBuilder:
                                                                (context, error,
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
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          4), // Add some space between message and timestamp
                                  (isSpecialMessage || isSpecialMessage2)
                                      ? Text(
                                          "", // Display formatted timestamp
                                        )
                                      : Text(
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
                              InkWell(
                                onTap: () {
                                  meetplace(context);
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InterestPage(
                                          tripUid: widget.tripUid!,
                                          placeid: widget.placeid),
                                    ),
                                  );
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
            print(widget.placeid);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => InfoPlacePage(
                      tripUid: widget.tripUid, placeid: widget.placeid)),
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
