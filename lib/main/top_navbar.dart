import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/EditProfile.dart';
import 'package:triptourapp/editpassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../authen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
            future:
                FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (userSnapshot.hasError) {
                return Text('Error: ${userSnapshot.error}');
              }
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Text('User data not found');
              }

              var userData = userSnapshot.data!.data() as Map<String, dynamic>;
              String? nickname = userData['nickname'];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('trips')
                    .where('tripJoin', arrayContains: uid)
                    .get(),
                builder: (context, tripSnapshot) {
                  if (tripSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (tripSnapshot.hasError) {
                    return Text('Error: ${tripSnapshot.error}');
                  }

                  List<DocumentSnapshot> trips = tripSnapshot.data!.docs;

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
                            nickname ?? '',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'จำนวนทริปที่เข้าร่วม : ${trips.length}',
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
              );
            },
          )),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          color: Colors.black,
          onPressed: () async {
            final result = await showMenu(
              context: context,
              position: RelativeRect.fromLTRB(100, 100, 0, 0),
              items: [
                PopupMenuItem(
                  child: Text(
                    'แก้ไขโปรไฟล์',
                    style: GoogleFonts.ibmPlexSansThai(),
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
                  Fluttertoast.showToast(msg: 'ออกจากระบบสำเร็จ');
                  break;
              }
            }
          },
        )
      ],
    );
  }
}
