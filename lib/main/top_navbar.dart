import 'package:flutter/material.dart';
import '../authen/login.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: EdgeInsets.all(0.0), // ปรับ margin ตามที่ต้องการ
        child: Row(
          children: [
            CircleAvatar(
              radius: 25.0,
              backgroundImage: AssetImage('assets/cat.jpg'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Travel Together',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'จำนวนทริปที่เข้าร่วม : 2',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LoginPage()), // RegisterPage() คือหน้าที่คุณต้องไป
            );
          },
        ),
      ],
    );
  }
}
