import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../infoplace.dart';

class UserPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTripItem(context),
      ],
    );
  }

  Widget buildTripItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfoPlacePage(),
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
                  'assets/userplan/userplan_image1.png',
                  width: 100.0,
                  height: 170.0,
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
                        InkWell(
                          onTap: () {},
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.remove),
                          ),
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
                    SizedBox(height: 3),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                        color: Color(0xffdc933c),
                      ),
                      padding: EdgeInsets.all(3.0),
                      child: Text(
                        'กำหนดการเวลา : 00:00',
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 8,
                          color: Colors.white, // สีของข้อความ
                          fontWeight: FontWeight.bold, // หนา
                          fontStyle: FontStyle.italic, // เอียง
                          // และคุณสามารถกำหนดคุณสมบัติอื่น ๆ ตามต้องการ
                        ),
                      ),
                    ),
                    Text('จำนวนผู้เข้าร่วม : 16',
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                    Text('ห่าง 15Km จากตำแหน่งของคุณ',
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // ทำอะไรเมื่อกดปุ่มเพิ่มสถานที่
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color.fromARGB(255, 63, 177, 88),
                              fixedSize: Size(70, 10),
                            ),
                            child: Text(
                              'เข้าร่วม',
                              style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10 // ทำให้เป็นตัวหนา
                                  // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // ทำอะไรเมื่อกดปุ่มกำหนดเวลาแต่ละสถานที่
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Color(0xffcfcfcf),
                              fixedSize: Size(70, 10),
                            ),
                            child: Text(
                              'จุดนัดพบ',
                              style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold, fontSize: 10),
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
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserPlan(),
  ));
}
