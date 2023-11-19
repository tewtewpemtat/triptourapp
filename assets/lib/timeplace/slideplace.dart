import 'package:flutter/material.dart';

class SlidePlace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTripItem(context),
        buildTripItem(context),
        buildTripItem(context),
      ],
    );
  }

  Widget buildTripItem(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
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
                  height: 130.0,
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
                    Text(
                      '1.ร้านจาคอฟฟี',
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // สีของเส้นกรอบ
                          width: 1.0, // ความหนาของเส้นกรอบ
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                        color: Colors.grey, // ความโค้งของมุมกรอบ
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
                        color: Colors.grey,
                      ),
                      padding: EdgeInsets.all(3.0),
                      child: Text(
                        'กำหนดการเวลา : 00:00',
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                    Text('จำนวนผู้เข้าร่วม : 16',
                        style: TextStyle(fontSize: 12)),
                    Text('ห่าง 15Km จากตำแหน่งของคุณ',
                        style: TextStyle(fontSize: 12)),
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
  runApp(MaterialApp(
    home: SlidePlace(),
  ));
}
