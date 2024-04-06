import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/placetimeline.dart';

class PlaceDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "ไทมไลน์ย่อย",
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
              MaterialPageRoute(builder: (context) => Placetimeline()),
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
                'เเสดงเวลา เช็คอิน - เช็คเอาท์',
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
              ), // Adjust the values as needed
              child: Text(
                'แสดงเวลา เช็คอิน-เช็คเอาท์ ของเเต่ละสถานที่ของคุณ',
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
    return Container(
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
                  SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Color(0xFF1E30D7), // ความโค้งของมุมกรอบ
                    ),
                    padding: EdgeInsets.all(3.0),
                    child: Text(
                      'กรุงเทพมหานคร',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 10,
                        color: Colors.white, // สีของข้อความ
                        // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                      ),
                    ),
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Color(0xffdb923c), // ความโค้งของมุมกรอบ
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          'เช็คอิน',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontSize: 10,
                            color: Colors.white, // สีของข้อความ
                            // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          ': 13:21  ',
                          style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.bold // สีของข้อความ
                              // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Color(0xffc21111), // ความโค้งของมุมกรอบ
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          'เช็คเอาท์',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontSize: 10,
                            color: Colors.white, // สีของข้อความ
                            // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          ': 13:21  ',
                          style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.bold // สีของข้อความ
                              // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PlaceDetail(),
  ));
}
