import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/tripmanage.dart';

class TripHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(10), // ระยะห่างระหว่างปุ่ม
          child: Align(
            alignment: Alignment.centerLeft, // จัดตำแหน่งข้อความไปทางซ้าย

            child: Text(
              'ทริปของคุณ',
              style: GoogleFonts.ibmPlexSansThai(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 10,
          ), // Adjust the values as needed
          child: Text(
            'แสดงทริปของคุณที่กำลังดำเนินการอยู่หรือทริปที่ยังไม่เริ่ม',
            style:
                GoogleFonts.ibmPlexSansThai(fontSize: 13, color: Colors.grey),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 9, // เปลี่ยน flex เป็น 7
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // สีของกรอบ
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            style:
                                GoogleFonts.ibmPlexSansThai(), // เพิ่มบรรทัดนี้
                            decoration: InputDecoration(
                              hintText: 'ค้นหาทริปของคุณ',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 13),
              Expanded(
                flex: 1, // หรือไม่ต้องใส่ flex เลย
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.menu, color: Colors.grey),
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
        SizedBox(height: 5),
        buildTripItem(context),
        buildTripItem(context),
        buildTripItem(context),
      ],
    );
  }

  Widget buildTripItem(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TripmanagePage()), // RegisterPage() คือหน้าที่คุณต้องไป
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius:
                BorderRadius.circular(10), // กำหนด BorderRadius ที่ต้องการ
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10), // กำหนด BorderRadius ที่ต้องการ
                  child: Container(
                    child: Image.asset(
                      'assets/main/main_image1.png',
                      width: 100.0,
                      height: 150.0,
                      fit: BoxFit.cover,
                    ),
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
                              'ชื่อทริป: จา',
                              style: GoogleFonts.ibmPlexSansThai(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.cancel, size: 16),
                            ),
                          ),
                        ],
                      ),
                      Text('สถานะทริป: กำลังดำเนินการ',
                          style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                      Text('เริ่มต้น กรุงเทพ สิ้นสุด กรุงเทพ',
                          style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                      Text('วันที่เดินทาง: 11/08/66 - 13/08/66',
                          style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                      Text('ผู้จัดทริป: ติว',
                          style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                      Text('จำนวนผู้ร่วมทริป: 16 คน',
                          style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
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

void main() {
  runApp(
    TripHistory(),
  );
}
