import 'package:flutter/material.dart';
import 'package:triptourapp/addplace.dart';
import 'package:triptourapp/tripmanage.dart';

import 'requestplace/downplace.dart';
import 'addplace/slideplace.dart';

class RequestPage extends StatefulWidget {
  @override
  final String? tripUid;
  // เพิ่ม callback function เพื่อส่งค่า placeType และ selectedOption ไปยัง DownPage

  const RequestPage({Key? key, this.tripUid}) : super(key: key);
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[350],
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPage(tripUid: widget.tripUid),
              ),
            );
          },
        ),
        title: Text('คำร้องขอ'),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'เพิ่มสถานที่',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'เพิ่มสถานที่บนทริปของคุณ',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RequestPage(),
  ));
}
