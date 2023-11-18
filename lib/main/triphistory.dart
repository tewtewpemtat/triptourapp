import 'package:flutter/material.dart';

class TripHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // จัดให้ข้อมูลบนสุดเริ่มจากด้านซ้าย
      children: [
        // ข้อความ "ประวัติทริป" อยู่บนสุด
        SizedBox(height: 20),
        Column(
          children: [
            Column(
              children: [
                Align(
                  child: Container(
                    width: 391,
                    height: 41,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffeaeaea),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'ค้นหาประวัติทริป',
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
              ],
            )
          ],
        ),
        SizedBox(height: 20),
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
        SizedBox(height: 7),
        // สร้างกล่องข้อความและรูป
        Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, // สีของเส้นกรอบ
              width: 1.0, // ความหนาของเส้นกรอบ
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4, // กำหนดขนาดของส่วนทางซ้าย (30%)
                child: Container(
                  child: Image.asset(
                    'assets/cat.jpg',
                    width: 100.0,
                    height: 140.0,
                    fit: BoxFit.cover, // ขยายเต็มส่วน
                  ),
                ),
              ),
              SizedBox(width: 13),
              Expanded(
                flex: 6, // กำหนดขนาดของส่วนทางขวา (70%)
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ชื่อทริป: จา', style: TextStyle(fontSize: 12)),
                      Text('สถานะทริป: กำลังดำเนินการ',
                          style: TextStyle(fontSize: 12)),
                      Row(
                        children: [
                          Text('รีวิว: ดีมาก\t\t\t',
                              style: TextStyle(fontSize: 12)),
                          Icon(Icons.location_on,
                              size: 12), // ใช้ icon แสดงตำแหน่ง
                          SizedBox(width: 5),
                          Text('100 เมตร', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Text('เริ่มต้น กรุงเทพ สิ้นสุด กรุงเทพ',
                          style: TextStyle(fontSize: 12)),
                      Text('วันที่เดินทาง: 11/08/66 - 13/08/66',
                          style: TextStyle(fontSize: 12)),
                      Text('ผู้จัดทริป: ติว', style: TextStyle(fontSize: 12)),
                      Text('จำนวนผู้ร่วมทริป: 16 คน',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // สร้างปุ่มจัดการทริป
      ],
    );
  }
}
