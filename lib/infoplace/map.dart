import 'package:flutter/material.dart';

class MemberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTripItem(),
        buildTripItem(),
      ],
    );
  }

  Widget buildTripItem() {
    return Material(
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black, // สีของเส้นกรอบ
            width: 1.0, // ความหนาของเส้นกรอบ
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                    Text('ชื่อทริป: จา', style: TextStyle(fontSize: 16)),
                  ],
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
    home: MemberPage(),
  ));
}