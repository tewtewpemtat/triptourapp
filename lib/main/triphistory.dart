import 'package:flutter/material.dart';

class TripHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(10),
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
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // โค้ดสำหรับการจัดการทริปที่นี่
                },
                child: Text('จัดการทริป'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // โค้ดสำหรับการเรียงลำดับทริปที่นี่
                },
                child: Text('เรียงลำดับ'),
              ),
            ],
          ),
        ),
        SizedBox(height: 7),
        buildTripItem(),
        buildTripItem(),
        buildTripItem(),
      ],
    );
  }

  Widget buildTripItem() {
    return InkWell(
      onTap: () {
        // ทำอะไรเมื่อคลิกที่รายการทริป
      },
      child: Material(
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
                      height: 160.0,
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
                      Text('ชื่อทริป: จา', style: TextStyle(fontSize: 12)),
                      Text('สถานะทริป: กำลังดำเนินการ',
                          style: TextStyle(fontSize: 12)),
                      Row(
                        children: [
                          Text('รีวิว: ดีมาก\t\t\t',
                              style: TextStyle(fontSize: 12)),
                          Icon(Icons.location_on, size: 12),
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
      ),
    );
  }
}

void main() {
  runApp(
    TripHistory(),
  );
}
