import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DownPage(),
  ));
}

class DownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white, // สีพื้นหลังของหน้า
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // สีของเส้นกรอบ
                      width: 1.0, // ความหนาของเส้นกรอบ
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3, // กำหนดขนาดของส่วนทางซ้าย (30%)
                        child: Container(
                          child: Image.asset(
                            'assets/cat.jpg',
                            width: 100.0,
                            height: 80.0,
                            fit: BoxFit.cover, // ขยายเต็มส่วน
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        flex: 6, // กำหนดขนาดของส่วนทางขวา (70%)
                        child: Container(
                          margin: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('เพิ่มจากคำร้องขอ',
                                  style: TextStyle(fontSize: 16)),
                              Text('เพิ่มสถานที่จากคำรองขอ',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // สีของเส้นกรอบ
                      width: 1.0, // ความหนาของเส้นกรอบ
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3, // กำหนดขนาดของส่วนทางซ้าย (30%)
                        child: Container(
                          child: Image.asset(
                            'assets/cat.jpg',
                            width: 100.0,
                            height: 80.0,
                            fit: BoxFit.cover, // ขยายเต็มส่วน
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        flex: 6, // กำหนดขนาดของส่วนทางขวา (70%)
                        child: Container(
                          margin: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('กำหนดเอง', style: TextStyle(fontSize: 16)),
                              Text('กำหนดสถานของคุณเอง',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {}, // ใส่โค้ดตอนคลิก
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // สีของเส้นกรอบ
                      width: 1.0, // ความหนาของเส้นกรอบ
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3, // กำหนดขนาดของส่วนทางซ้าย (30%)
                        child: Container(
                          child: Image.asset(
                            'assets/cat.jpg',
                            width: 100.0,
                            height: 80.0,
                            fit: BoxFit.cover, // ขยายเต็มส่วน
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        flex: 5, // กำหนดขนาดของส่วนทางขวา (70%)
                        child: Container(
                          margin: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ร้านกาเเฟ WhiteCafe',
                                  style: TextStyle(fontSize: 16)),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: Colors.grey,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 2.0),
                                child: Text(
                                  'นนทบุรี',
                                  style: TextStyle(fontSize: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(top: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.add,
                                size: 24.0, // ปรับขนาดไอคอนตามที่ต้องการ
                                color: Colors.blue, // เลือกสีตามที่ต้องการ
                              ),
                              // เพิ่มวิดเจ็ตอื่น ๆ ที่คุณต้องการที่นี่
                            ],
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
      ),
    );
  }
}
