import 'package:flutter/material.dart';

class TripTimeLineHistory extends StatelessWidget {
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
          margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10), // กำหนด BorderRadius ที่ต้องการ
                  child: Container(
                    child: Image.asset(
                      'assets/main/main_image1.png',
                      width: 100.0,
                      height: 125.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                flex: 7,
                child: Container(
                  margin: EdgeInsets.all(0.0),
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // สีเทาอ่อน

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
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Image.asset('assets/pencil.png',
                                width: 18, height: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'รีวิว: ดีมาก\t\t\t',
                            style: TextStyle(fontSize: 12),
                          ),
                          Image.asset('assets/red.png', width: 14, height: 14),
                          Text('\t ทริปสิ้นสุดลงเเล้ว ',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('วันที่เดินทาง: 11/08/66 - 13/08/66',
                              style: TextStyle(fontSize: 12)),
                          Icon(Icons.location_on,
                              size: 12), // ใช้ icon แสดงตำแหน่ง
                          SizedBox(width: 5),
                          Text('100 เมตร', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Text('เริ่มต้น กรุงเทพ สิ้นสุด กรุงเทพ',
                          style: TextStyle(fontSize: 12)),
                      Text('ผู้จัดทริป: ติว\t\t\t\t\t\t\t',
                          style: TextStyle(fontSize: 12)),
                      Row(
                        children: [
                          Text('จำนวนผู้ร่วมทริป: 12 คน \t\t\t',
                              style: TextStyle(fontSize: 12)),
                          Text('ผู้ร่วมทริปสูงสุด : 12',
                              style: TextStyle(fontSize: 12)),
                        ],
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

void main() {
  runApp(
    TripTimeLineHistory(),
  );
}
