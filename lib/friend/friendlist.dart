import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../privatechat.dart';

class FriendList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTripItem(context),
        buildTripItem(context),
      ],
    );
  }

  Widget buildTripItem(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreenPage(),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey, // สีของเส้นกรอบ
              width: 1.0, // ความหนาของเส้นกรอบ
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.all(4.0),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/cat.jpg',
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
                              'JaThankyou',
                              style: GoogleFonts.ibmPlexSansThai(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 3.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Color(0xffdc933c),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '12',
                              style: GoogleFonts.ibmPlexSansThai(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
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
  }
}

void main() {
  runApp(MaterialApp(
    home: FriendList(),
  ));
}
