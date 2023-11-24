import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/tripmanage.dart';

void main() {
  runApp(GroupScreenPage());
}

class GroupScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, String>> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "แชทกลุ่ม",
          style: GoogleFonts.ibmPlexSansThai(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TripmanagePage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatMessage(
                  user: message['user']!,
                  message: message['message']!,
                  isYou: message['user'] == 'You',
                );
              },
            ),
          ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildChatMessage(
      {required String user, required String message, required bool isYou}) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isYou)
            Container(
              margin: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isYou ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style:
                      GoogleFonts.ibmPlexSansThai(fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isYou ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    message,
                    style: GoogleFonts.ibmPlexSansThai(
                        color: isYou ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          ),
          if (isYou)
            Container(
              margin: EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
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
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Start typing...',
                        contentPadding: EdgeInsets.all(16.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      // Handle send icon tap
                      _sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {
              // Handle mic icon tap
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      _messageController.clear();
      setState(() {
        _messages.add({'user': 'You', 'message': message});
      });
    }
  }
}
