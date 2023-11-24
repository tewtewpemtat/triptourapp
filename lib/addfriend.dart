import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/friend.dart';

void main() {
  runApp(AddFriend());
}

class AddFriend extends StatelessWidget {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Friend(),
                  ),
                );
              },
              icon: Icon(Icons.arrow_back),
            ),
          ), // เรียกใช้ TopNavbar Widgetna
          resizeToAvoidBottomInset: false, // เพิ่มการตั้งค่านี้
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                buildTripItem(context),
                buildTripItem(context),
              ],
            ),
          )),
    );
  }

  Widget buildTripItem(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {},
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
                      width: 50.0,
                      height: 60.0,
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
                              'JaGUARxKAI',
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
                              borderRadius: BorderRadius.circular(20.0),
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
  }
}
