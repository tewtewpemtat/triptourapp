import 'package:flutter/material.dart';

class PlaceSum extends StatelessWidget {
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
          borderRadius: BorderRadius.circular(10), // มุมโค้งของ Container
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/userplan/userplan_image1.png',
                  width: 100.0,
                  height: 160.0,
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
                        InkWell(
                          onTap: () {},
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.remove),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // สีของเส้นกรอบ
                          width: 1.0, // ความหนาของเส้นกรอบ
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                        color: Color(0xFF1E30D7), // ความโค้งของมุมกรอบ
                      ),
                      padding: EdgeInsets.all(3.0),
                      child: Text(
                        'กรุงเทพมหานคร',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white, // สีของข้อความ
                          // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                        ),
                      ),
                    ),
                    Text(
                        '164/694 ถนนกาเน เขตหนองมา แขวงหนองลิง กรุงเทพมหานคร 15000',
                        style: TextStyle(fontSize: 12)),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Color(0xffdb923c), // ความโค้งของมุมกรอบ
                          ),
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            'เวลาเริ่มต้น',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white, // สีของข้อความ
                              // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            ': 13:21  ',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.bold // สีของข้อความ
                                // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Color(0xffdb923c), // ความโค้งของมุมกรอบ
                          ),
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            'เวลาสิ้นสุด',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white, // สีของข้อความ
                              // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            ': 13:21  ',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.bold // สีของข้อความ
                                // สามารถเพิ่มคุณสมบัติอื่น ๆ ตามต้องการ
                                ),
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
  runApp(MaterialApp(
    home: PlaceSum(),
  ));
}
