import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/invite.dart';
import 'package:triptourapp/main.dart';
import 'tripmanage/headbutton.dart';
import 'tripmanage/headplan.dart';
import 'tripmanage/headinformation.dart';

class TripmanagePage extends StatelessWidget {
  final String? tripUid;
  const TripmanagePage({Key? key, this.tripUid})
      : super(key: key); // Constructor ที่รับค่า UID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'แผนการเดินทาง',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansThai(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.person_add),
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Invite(tripUid: tripUid)),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InformationPage(tripUid: tripUid),
            HeadButton(tripUid: tripUid),
            HeadPlan(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TripmanagePage(),
  ));
}
