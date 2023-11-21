import 'package:flutter/material.dart';

class TripHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      border: Border.all(color: Colors.black), // สีของกรอบ
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 5),
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
        buildTripItem(),
        buildTripItem(),
        buildTripItem(),
      ],
    );
  }

  Widget buildTripItem() {
    return Material(
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
                borderRadius:
                    BorderRadius.circular(10), // กำหนด BorderRadius ที่ต้องการ
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
                    Text(
                      'ชื่อทริป: จา',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text('จำนวนผู้ร่วมทริป: 16 คน',
                              style: TextStyle(fontSize: 12)),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.delete, size: 16),
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
  runApp(
    TripHistory(),
  );
}
