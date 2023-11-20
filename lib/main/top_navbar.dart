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
                  'Jaguar',
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
          onPressed: () async {
            final result = await showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                  100, 100, 0, 0), // ปรับตำแหน่งที่เปิด Slide ทางขวา
              items: [
                PopupMenuItem(
                  child: Text('แก้ไขโปรไฟล์'),
                  value: 'editProfile',
                ),
                PopupMenuItem(
                  child: Text('แก้ไขข้อมูลส่วนตัว'),
                  value: 'editPersonalInfo',
                ),
                PopupMenuItem(
                  child: Text('ออกจากระบบ'),
                  value: 'logout',
                ),
              ],
            );

            // ตรวจสอบผลลัพธ์และดำเนินการตามต้องการ
            if (result != null) {
              switch (result) {
                case 'editProfile':
                  // ทำงานเมื่อเลือกแก้ไขโปรไฟล์
                  break;
                case 'editPersonalInfo':
                  // ทำงานเมื่อเลือกแก้ไขข้อมูลส่วนตัว
                  break;
                case 'logout':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                  break;
              }
            }
          },
        )
      ],
    );
  }
}
