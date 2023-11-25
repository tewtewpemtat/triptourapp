import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/triptimeline.dart';

import 'placedetailtimeline.dart';

class PlaceTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "ไทมไลน์",
          style: GoogleFonts.ibmPlexSansThai(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TripTimeLine()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(
                10,
              ), // Adjust the values as needed
              child: Text(
                'จำนวนสถานที่ทั้งหมด',
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 10,
              ), // Adjust the values as needed
              child: Text(
                'แสดงไทมไลน์ของเเต่ละสถานที่ของคุณ',
                style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 13, color: Colors.grey),
              ),
            ),
            buildTripItem(context),
            buildTripItem(context),
            buildTripItem(context),
          ],
        ),
      ),
    );
  }

  Widget buildTripItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetail(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey, // สีของเส้นกรอบ
            width: 1.0, // ความหนาของเส้นกรอบ
          ),
          borderRadius: BorderRadius.circular(10), // มุมโค้งของ Container
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/headplan/headplan_image1.png',
                  width: 100.0,
                  height: 120.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              flex: 6,
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1.ร้านจาคอฟฟี',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey, // สีของเส้นกรอบ
                          width: 1.0, // ความหนาของเส้นกรอบ
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                        color: Color(0xFF1E30D7), // ความโค้งของมุมกรอบ
                      ),
                      padding: EdgeInsets.all(3.0),
                      child: Text(
                        'กรุงเทพมหานคร',
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 8,
                          color: Colors.white, // สีของข้อความ
                          // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text('จำนวนผู้เข้าร่วม : 16',
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                    Text('เริ่มต้น : 11/08/66 เวลา : 13:12',
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                    Text('เริ่มต้น : 11/08/66 เวลา : 13:45',
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PlaceTimeline(),
  ));
}
