import 'package:flutter/material.dart';
import '../authen/login.dart';

class TimeLineTopNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Travel Together'),
      actions: [
        IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            // ไปยังหน้าโปรไฟล์
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
