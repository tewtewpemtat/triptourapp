import 'package:flutter/material.dart';

class MemberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 8),
          child: Row(
            children: [
              SizedBox(width: 10),
              Text(
                'สมาชิกที่เข้าร่วม',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
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
            color: Colors.grey, // สีของเส้นกรอบ
            width: 1.0, // ความหนาของเส้นกรอบ
          ),
          borderRadius: BorderRadius.circular(10.0),
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
                    Text(
                      'JaGUARxKAI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight
                            .bold, // เพิ่มคำสั่งนี้เพื่อทำให้ตัวอักษรเป็นตัวหนา
                      ),
                    ),
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
