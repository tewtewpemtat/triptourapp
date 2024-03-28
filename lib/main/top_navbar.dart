import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/EditProfile.dart';
import 'package:triptourapp/editpassword.dart';
import '../authen/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../authen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return AppBar(
      backgroundColor: Colors.grey[200],
      title: Padding(
        padding: EdgeInsets.all(0.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // หรือ Widget ที่คุณต้องการแสดงขณะโหลดข้อมูล
            }

            if (snapshot.hasError) {
              return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('ไม่พบข้อมูลผู้ใช้');
            }

            // ดึงข้อมูลจาก snapshot
            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return Row(
              children: [
                CircleAvatar(
                  radius: 25.0,
                  backgroundImage: userData['profileImageUrl'] != null
                      ? NetworkImage(userData['profileImageUrl'])
                      : AssetImage('assets/profile.jpg') as ImageProvider,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['nickname'] ?? '',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'จำนวนทริปที่เข้าร่วม : ${userData['triplist'] ?? 0}',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
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
                  FirebaseAuth.instance.signOut();
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
