import 'package:flutter/material.dart';

class UserPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTripItem(),
        buildTripItem(),
        buildTripItem(),
      ],
    );
  }

  Widget buildTripItem() {
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black, // สีของเส้นกรอบ
          width: 1.0, // ความหนาของเส้นกรอบ
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              child: Image.asset(
                'assets/cat.jpg',
                width: 100.0,
                height: 165.0,
                fit: BoxFit.cover,
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
                          '1.ร้านจาคอฟฟี',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.remove)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black, // สีของเส้นกรอบ
                        width: 1.0, // ความหนาของเส้นกรอบ
                      ),
                      borderRadius:
                          BorderRadius.circular(16.0), // ความโค้งของมุมกรอบ
                    ),
                    padding: EdgeInsets.all(3.0), // การกำหนด padding
                    child: Text(
                      'กรุงเทพมหานคร',
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding: EdgeInsets.all(3.0),
                    child: Text(
                      'กำหนดการเวลา : 00:00',
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
                  Text('จำนวนผู้เข้าร่วม : 16', style: TextStyle(fontSize: 12)),
                  Text('ห่าง 15Km จากตำแหน่งของคุณ',
                      style: TextStyle(fontSize: 12)),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // ทำอะไรเมื่อกดปุ่มเพิ่มสถานที่
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.black,
                            fixedSize: Size(20, 20),
                          ),
                          child: Text('เข้าร่วม'),
                        ),
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // ทำอะไรเมื่อกดปุ่มกำหนดเวลาแต่ละสถานที่
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.black,
                            fixedSize: Size(20, 20),
                          ),
                          child: Text('จุดนัดพบ'),
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserPlan(),
  ));
}
