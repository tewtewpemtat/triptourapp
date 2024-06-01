import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/tripmanage.dart';
import 'addplace/downplace.dart';

class AddPage extends StatelessWidget {
  final String? tripUid;
  const AddPage({Key? key, this.tripUid}) : super(key: key);
  void searchPlaces(String query, BuildContext context) {
    Navigator.pop(context, query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[350],
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripmanagePage(tripUid: tripUid),
              ),
            );
          },
        ),
        title: Text('เพิ่มสถานที่'),
      ),
      body: Container(
        color: Color(0xFFF0F0F0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'เพิ่มสถานที่บนทริปของคุณ',
                style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 14.0, color: Colors.grey),
              ),
            ),
            Expanded(
              child: DownPage(tripUid: tripUid),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddPage(),
  ));
}
