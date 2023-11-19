import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // สีเทาอ่อน
        border: Border.all(
          color: Colors.black, // สีดำ
          width: 2.0, // ความหนาของเส้นกรอบ
        ),
        borderRadius: BorderRadius.circular(0.0), // มุมเเหลม
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                child: Image.asset('assets/pencil.png', width: 18, height: 18),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'จำนวนผู้ร่วมทริป: 16 คน \t\t\t\t\t\t\t\t\t\t',
                style: TextStyle(fontSize: 16),
              ),
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
          Row(
            children: [
              Text('ผู้จัดทริป: ติว\t\t\t\t\t\t\t',
                  style: TextStyle(fontSize: 16)),
              Text('ผู้ร่วมทริปสูงสุด : 12', style: TextStyle(fontSize: 16)),
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
