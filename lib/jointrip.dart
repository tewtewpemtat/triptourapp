import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: JoinTripPage(),
  ));
}

class JoinTripPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ตอบรับคำเชิญเพื่อเข้าร่วมทริป"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: InkWell(
          onTap: () {},
          child: Container(
            color: Colors.white, // สีพื้นหลังของหน้า
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/jointrip/mail_image1.png',
                              width: 100.0,
                              height: 80.0,
                              fit: BoxFit.cover, // ขยายเต็มส่วน
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 6, // กำหนดขนาดของส่วนทางขวา (70%)
                        child: Container(
                          margin: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('คุณได้รับคำเชิญจาก',
                                  style: TextStyle(fontSize: 16)),
                              Text('Jaguar', style: TextStyle(fontSize: 12)),
                              Text('ทริปเที่ยวกับจากั้ว',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
