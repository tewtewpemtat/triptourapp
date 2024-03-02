import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriend extends StatefulWidget {
  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  String? myUid = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTour',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: Text(
            "เพิ่มเพื่อน",
            style: GoogleFonts.ibmPlexSansThai(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
          leading: IconButton(
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  'เพิ่มเพื่อนของคุณ',
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 2),
              Container(
                margin: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  'กรอกชื่อเพื่อนคุณเพื่อค้นหาเพื่อนในแอปพลิเคชัน TripTour',
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 3),
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
                            _performSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'ค้นหาเพื่อน',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              buildSearchResults(),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      // Get the current user's friend list
      DocumentSnapshot currentUserSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(myUid).get();
      List<String> currentUserFriendList =
          List<String>.from(currentUserSnapshot['friendList']);

      QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThan: query + 'z')
          .get();

      setState(() {
        // Filter out users who are already friends
        _searchResults = result.docs.where((user) {
          String uid = user.id;
          return !currentUserFriendList.contains(uid);
        }).toList();
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Widget buildSearchResults() {
    return Column(
      children: _searchResults.map((user) {
        String firstName = user['firstName'];
        String lastName = user['lastName'];
        String proFilepic = user['profileImageUrl'];
        return buildFriendItem(
            context, firstName, lastName, user.id, proFilepic);
      }).toList(),
    );
  }

  Widget buildFriendItem(context, String firstName, String lastName, String uid,
      String profileImageUrl) {
    // ตรวจสอบว่าเป็น UID ของผู้ใช้ปัจจุบันหรือไม่
    if (uid != myUid) {
      return FutureBuilder<bool>(
        future: checkIfFriend(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            bool isFriend = snapshot.data ?? false;
            if (!isFriend) {
              // แสดงผลลัพธ์เฉพาะเมื่อไม่ใช่เพื่อน
              return Material(
                child: InkWell(
                  onTap: () {
                    sendFriendRequest(uid);
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
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.all(4.0),
                            child: ClipOval(
                              child: profileImageUrl.isNotEmpty
                                  ? Image.network(
                                      profileImageUrl,
                                      width: 70.0,
                                      height: 70.0,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/cat.jpg', // A default image in case there is no profile image.
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
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        '$firstName $lastName',
                                        style: GoogleFonts.ibmPlexSansThai(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 5.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        color: Color(0xffdc933c),
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // ไม่แสดงผลลัพธ์ถ้าเป็นเพื่อนแล้ว
              return Container();
            }
          }
        },
      );
    } else {
      // ไม่แสดงผลลัพธ์ถ้า UID เป็นของผู้ใช้ปัจจุบัน
      return Container();
    }
  }

  Future<bool> checkIfFriend(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      print("hi");
      List<String> friendList = List<String>.from(userSnapshot['friendList']);

      // ตรวจสอบว่า uid นี้อยู่ใน friendList หรือไม่
      return friendList.contains(uid);
    } catch (e) {
      print('Error checking if friend: $e');
      return false;
    }
  }
}

void sendFriendRequest(String friendUid) async {
  try {
    // Get the current user's UID
    String? myUid = FirebaseAuth.instance.currentUser?.uid;

    // Check if there is an existing friend request with the specified conditions
    QuerySnapshot existingRequests = await FirebaseFirestore.instance
        .collection('friendrequest')
        .where('senderUid', isEqualTo: myUid)
        .where('receiverUid', isEqualTo: friendUid)
        .where('status', isEqualTo: 'Wait')
        .get();

    if (existingRequests.docs.isEmpty) {
      // If no existing request, then add a new friend request
      await FirebaseFirestore.instance.collection('friendrequest').add({
        'senderUid': myUid,
        'receiverUid': friendUid,
        'status': 'Wait',
        // You can add more fields if needed
      });

      // Display a success message or perform any other actions as needed
      print('Friend request sent successfully.');
    } else {
      // Display a message indicating that a friend request already exists
      print('Friend request already exists.');
    }
  } catch (e) {
    // Handle errors
    print('Error sending friend request: $e');
  }
}

void main() {
  runApp(AddFriend());
}
