import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.only(
            left: 10,
          ),
          child: Text(
            'รายชื่อเพื่อน',
            style: GoogleFonts.ibmPlexSansThai(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 2),
        Container(
          margin: EdgeInsets.only(
            left: 10,
          ),
          child: Text(
            'แชทส่วนตัวเพื่อสนทนาในเเอปพลิเคชั่น TripTour',
            style:
                GoogleFonts.ibmPlexSansThai(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(
    FriendButton(),
  );
}
