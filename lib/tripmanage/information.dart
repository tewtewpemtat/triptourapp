import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ชื่อทริป: จา',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child:
                      Image.asset('assets/pencil.png', width: 18, height: 18),
                ),
              ],
            ),
            Row(
              children: [
                Text('จำนวนผู้ร่วมทริป: 16 คน \t\t\t\t\t\t\t\t\t\t',
                    style: TextStyle(fontSize: 16)),
                Image.asset('assets/green.png', width: 14, height: 14),
                Text('\t กำลังดำเนินการ ', style: TextStyle(fontSize: 16)),
              ],
            ),
            Row(
              children: [
                Text('รีวิว: ดีมาก\t\t\t', style: TextStyle(fontSize: 16)),
                Icon(Icons.location_on, size: 16), // ใช้ icon แสดงตำแหน่ง
                SizedBox(width: 5),
                Text('100 เมตร', style: TextStyle(fontSize: 16)),
              ],
            ),
            Text('เริ่มต้น กรุงเทพ สิ้นสุด กรุงเทพ',
                style: TextStyle(fontSize: 16)),
            Text('วันที่เดินทาง: 11/08/66 - 13/08/66',
                style: TextStyle(fontSize: 16)),
            Text('ผู้จัดทริป: ติว', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InformationPage(),
  ));
}
