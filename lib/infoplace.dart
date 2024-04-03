import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/tripmanage.dart';

import 'infoplace/groupchat.dart';
import 'infoplace/headinfobutton.dart';
import 'infoplace/infomationplace.dart';
import 'infoplace/member.dart';

class InfoPlacePage extends StatefulWidget {
  @override
  final String? tripUid;
  final String? placeid;
  const InfoPlacePage({Key? key, this.tripUid, this.placeid}) : super(key: key);

  InfoPlacePageState createState() => InfoPlacePageState();
}

class InfoPlacePageState extends State<InfoPlacePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripmanagePage(tripUid: widget.tripUid),
              ),
            );
          },
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
              color: Colors.black,
              icon: Icon(Icons.chat),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupScreenPage(
                              tripUid: widget.tripUid ?? '',
                              placeid: widget.placeid ?? '',
                            )));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InformationPlan(tripUid: widget.tripUid, placeid: widget.placeid),
            HeadInfoButton(),
            MemberPage()
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InfoPlacePage(),
  ));
}
