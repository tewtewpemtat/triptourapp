import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/EditProfile.dart';
import 'package:triptourapp/EditUser.dart';

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
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'จำนวนทริปที่เข้าร่วม : 2',
                  style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 13, color: Colors.black),
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(),
                    ),
                  );
                  break;
                case 'editPersonalInfo':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserPage(),
                    ),
                  );
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
