import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/addplace/slideplace.dart';
import 'package:triptourapp/requestlist.dart';

void main() {
  runApp(MaterialApp(
    home: DownPage(),
  ));
}

class DownPage extends StatelessWidget {
  final String? tripUid;
  const DownPage({Key? key, this.tripUid}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFF0F0F0), // สีพื้นหลังของหน้า
          padding: EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: SlidePlace(tripUid: tripUid),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestList(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // เพิ่มบรรทัดนี้
                    border: Border.all(
                      color: Colors.grey, // สีของเส้นกรอบ
                      width: 1.0, // ความหนาของเส้นกรอบ
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/addplace/addplace_image1.png',
                              width: 100.0,
                              height: 80.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        flex: 7,
                        child: Container(
                          margin: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('เพิ่มจากคำร้องขอ',
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text('เพิ่มสถานที่จากคำร้องขอ',
                                  style: GoogleFonts.ibmPlexSansThai(
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // เพิ่มบรรทัดนี้
                    border: Border.all(
                      color: Colors.grey, // สีของเส้นกรอบ
                      width: 1.0, // ความหนาของเส้นกรอบ
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/addplace/addplace_image2.png',
                              width: 100.0,
                              height: 80.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        flex: 7,
                        child: Container(
                          margin: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('กำหนดเอง',
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text('กำหนดสถานที่ของคุณเอง',
                                  style: GoogleFonts.ibmPlexSansThai(
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {}, // ใส่โค้ดตอนคลิก
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey, // สีของเส้นกรอบ
                      width: 1.0, // ความหนาของเส้นกรอบ
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3, // กำหนดขนาดของส่วนทางซ้าย (30%)
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/userplan/userplan_image1.png',
                              width: 100.0,
                              height: 80.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        flex: 6, // กำหนดขนาดของส่วนทางขวา (70%)
                        child: Container(
                          margin: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ร้านกาเเฟ WhiteCafe',
                                  style: GoogleFonts.ibmPlexSansThai(
                                    fontSize: 16,
                                  )),
                              SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: Color(0xFF1E30D7),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 1.0),
                                child: Text(
                                  'นนทบุรี',
                                  style: GoogleFonts.ibmPlexSansThai(
                                      fontSize: 11, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(top: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.add,
                                size: 24.0, // ปรับขนาดไอคอนตามที่ต้องการ
                                color: Colors.blue, // เลือกสีตามที่ต้องการ
                              ),
                              // เพิ่มวิดเจ็ตอื่น ๆ ที่คุณต้องการที่นี่
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
