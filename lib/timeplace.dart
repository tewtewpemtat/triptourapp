import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/timeplace/placesum.dart';
import 'package:triptourapp/timeplace/slideplace.dart';
import 'package:triptourapp/timeplace/slidetime.dart';

class TimePlacePage extends StatefulWidget {
  @override
  final String? tripUid;
  const TimePlacePage({Key? key, this.tripUid}) : super(key: key);
  _TimePlacePageState createState() => _TimePlacePageState();
}

class _TimePlacePageState extends State<TimePlacePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'จัดการเวลา',
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSansThai(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'เลือกสถานที่',
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'เลือกสถานที่เพื่อกำหนดเวลา',
                style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 14.0, color: Colors.grey),
              ),
            ),
            SlidePlace(tripUid: widget.tripUid),
            // Padding(
            //   padding: const EdgeInsets.only(left: 10),
            //   child: Text(
            //     'กำหนดเวลา',
            //     style: GoogleFonts.ibmPlexSansThai(
            //       fontSize: 24.0,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            // SizedBox(height: 5),
            // Padding(
            //   padding: const EdgeInsets.only(left: 10),
            //   child: Text(
            //     'ระบุเวลาการเดินทางของแต่ละสถานที่',
            //     style: GoogleFonts.ibmPlexSansThai(
            //         fontSize: 14.0, color: Colors.grey),
            //   ),
            // ),

            SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'การกำหนดการเวลาแต่ละสถานที่',
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PlaceSum(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TimePlacePage(),
  ));
}
