import 'package:flutter/material.dart';

class TripHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // จัดให้ข้อมูลบนสุดเริ่มจากด้านซ้าย
      children: [
        // ข้อความ "ประวัติทริป" อยู่บนสุด
        Padding(
          padding: EdgeInsets.only(left: 16), // เพิ่ม Padding ไปทางซ้าย
          child: Text(
            'ประวัติทริป',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // สร้างส่วนของการค้นหา
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'ค้นหาประวัติทริป',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        // สร้างปุ่มจัดการทริปและเรียงลำดับ
        Padding(
          padding: EdgeInsets.only(
            left: 16,
          ),
          child: Row(
            // จัดตำแหน่งปุ่ม
            children: [
              ElevatedButton(
                onPressed: () {
                  // เพิ่มโค้ดสำหรับการจัดการทริปที่นี่
                },
                child: Text('จัดการทริป'),
              ),
              SizedBox(width: 10), // เพิ่มระยะห่างระหว่างปุ่ม
              ElevatedButton(
                onPressed: () {
                  // เพิ่มโค้ดสำหรับการเรียงลำดับทริปที่นี่
                },
                child: Text('เรียงลำดับ'),
              ),
            ],
          ),
        ),
        // สร้างกล่องข้อความและรูป
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  'assets/cat.jpg', // แทนชื่อไฟล์รูปภาพที่คุณต้องการแสดง
                  fit: BoxFit.cover, // ปรับขนาดรูปภาพให้เต็ม Container
                ),
              ),
              SizedBox(width: 13), // เพิ่มระยะห่างระหว่างรูปภาพและข้อความ
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ชื่อทริป: จา',
                      style: TextStyle(fontSize: 11)), // ปรับขนาดข้อความ
                  Text('รีวิว: ดีมาก',
                      style: TextStyle(fontSize: 11)), // ปรับขนาดข้อความ
                  Text('สถานะทริป: ยอดเยี่ยม',
                      style: TextStyle(fontSize: 11)), // ปรับขนาดข้อความ
                  Text('ระยะทางทริป: 100 เมตร',
                      style: TextStyle(fontSize: 11)), // ปรับขนาดข้อความ
                  Text('เริ่มต้นกรุงเทพสิ้นสุดกรุงเทพ',
                      style: TextStyle(fontSize: 11)), // ปรับขนาดข้อความ
                  Text('วันที่เดินทาง: 11/08/66 - 13/08/66',
                      style: TextStyle(fontSize: 11)), // ปรับขนาดข้อความ
                  Text('ผู้จัดทริป: ติว',
                      style: TextStyle(fontSize: 11)), // ปรับขนาดข้อความ
                  Text('จำนวนผู้ร่วมทริป: 16 คน',
                      style: TextStyle(fontSize: 11)), // ปรับขนาดข้อความ
                ],
              ),
            ],
          ),
        ),
        // สร้างปุ่มจัดการทริป
      ],
    );
  }
}
