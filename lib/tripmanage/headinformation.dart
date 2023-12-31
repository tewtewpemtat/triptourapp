import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/edittrip.dart';

class InformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // สีเทาอ่อน

        borderRadius: BorderRadius.circular(0.0), // มุมเเหลม
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // สีและความโปร่งใสของเงา
            spreadRadius: 3, // การกระจายขอบของเงา
            blurRadius: 6, // ความเบลอของเงา
            offset: Offset(0, 1), // ตำแหน่งของเงา (นอน, ตั้ง)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ชื่อทริป: จา',
                  style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EditTrip()),
                  );
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child:
                      Image.asset('assets/pencil.png', width: 18, height: 18),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'จำนวนผู้ร่วมทริป: 16 คน \t\t\t\t\t\t\t\t\t\t',
                style: GoogleFonts.ibmPlexSansThai(fontSize: 16),
              ),
              Image.asset('assets/green.png', width: 14, height: 14),
              Text('\t กำลังดำเนินการ ',
                  style: GoogleFonts.ibmPlexSansThai(fontSize: 16)),
            ],
          ),
          Text('เริ่มต้น กรุงเทพ สิ้นสุด กรุงเทพ',
              style: GoogleFonts.ibmPlexSansThai(fontSize: 16)),
          Text('วันที่เดินทาง: 11/08/66 - 13/08/66',
              style: GoogleFonts.ibmPlexSansThai(fontSize: 16)),
          Row(
            children: [
              Text('ผู้จัดทริป: ติว\t\t\t\t\t\t\t',
                  style: GoogleFonts.ibmPlexSansThai(fontSize: 16)),
              Text('ผู้ร่วมทริปสูงสุด : 12',
                  style: GoogleFonts.ibmPlexSansThai(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InformationPage(),
  ));
}
