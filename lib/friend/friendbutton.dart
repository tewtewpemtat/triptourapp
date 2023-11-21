import 'package:flutter/material.dart';
import '../placetimeline.dart';

class FriendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
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
                      hintText: 'ค้นหาเพื่อนของคุณ',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 10,
          ), // Adjust the values as needed
          child: Text(
            'รายชื่อเพื่อน',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 2),
        Container(
          margin: EdgeInsets.only(
            left: 10,
          ), // Adjust the values as needed
          child: Text(
            'แชทส่วนตัวเพื่อสนทนาในเเอปพลิเคชั่น Trip Tour',
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 10),
                      Text('เพิ่มเพื่อน', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Icon(Icons.menu),
              ),
            ],
          ),
        ),
        SizedBox(height: 7),
      ],
    );
  }
}

void main() {
  runApp(
    FriendButton(),
  );
}
