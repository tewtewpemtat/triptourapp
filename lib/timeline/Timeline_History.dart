import 'package:flutter/material.dart';
import '../placetimeline.dart';

class TripTimeLineHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3),
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
        SizedBox(height: 5),
        Container(
          margin: EdgeInsets.only(
            left: 10,
          ), // Adjust the values as needed
          child: Text(
            'ไทมไลน์ของคุณ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 7),
        buildTripItem(context),
        buildTripItem(context),
        buildTripItem(context),
      ],
    );
  }

  Widget buildTripItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceTimeline(),
          ),
        );
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ชื่อทริป: จา',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                          Icon(Icons.location_on, size: 12),
                          Text('100 เมตร', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 5),
                          Text('เริ่มต้น กรุงเทพ สิ้นสุด กรุงเทพ',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Text(
                        'วันที่เดินทาง: 11/08/66 - 13/08/66',
                      ),
                      Text('ผู้จัดทริป: ติว\t\t\t\t\t\t\t',
                          style: TextStyle(fontSize: 12)),
                      Row(
                        children: [
                          Text('จำนวนผู้ร่วมทริป: 12 คน \t\t\t',
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
