import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/EditProfile.dart';
import 'package:triptourapp/editpassword.dart';

import '../authen/login.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[200],
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
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
          color: Colors.black,
          onPressed: () async {
            final result = await showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                  100, 100, 0, 0), // ปรับตำแหน่งที่เปิด Slide ทางขวา
              items: [
                PopupMenuItem(
                  child: Text(
                    'แก้ไขโปรไฟล์',
                    style: GoogleFonts.ibmPlexSansThai(), // เพิ่มบรรทัดนี้
                  ),
                  value: 'editProfile',
                ),
                PopupMenuItem(
                  child: Text(
                    'แก้ไขรหัสผ่าน',
                    style: GoogleFonts.ibmPlexSansThai(),
                  ),
                  value: 'editPassword',
                ),
                PopupMenuItem(
                  child: Text(
                    'ออกจากระบบ',
                    style: GoogleFonts.ibmPlexSansThai(),
                  ),
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
                case 'editPassword':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUser(),
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
