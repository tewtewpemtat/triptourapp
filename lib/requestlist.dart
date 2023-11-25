import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/addplace.dart';

class RequestList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "คำร้องขอ",
          style: GoogleFonts.ibmPlexSansThai(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPage(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTripItem(context),
          buildTripItem(context),
          buildTripItem(context),
        ],
      ),
    );
  }

  Widget buildTripItem(BuildContext context) {
    return InkWell(
      onTap: () {},
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
                  'assets/userplan/userplan_image1.png',
                  width: 100.0,
                  height: 140.0,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '1.ร้านจาคอฟฟี',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.add),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // สีของเส้นกรอบ
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
                    Text(
                        '164/694 ถนนกาเน เขตหนองมา แขวงหนองลิง กรุงเทพมหานคร 15000',
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
    home: RequestList(),
  ));
}
