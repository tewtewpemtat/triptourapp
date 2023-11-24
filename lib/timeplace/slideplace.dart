import 'package:flutter/material.dart';

class SlidePlace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.0, // Set a specific height for the container
      child: PageView(
        children: [
          buildTripItem(context),
          buildTripItem(context),
          buildTripItem(context),
        ],
      ),
    );
  }

  Widget buildTripItem(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Handle tap action
        },
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      'assets/cat.jpg',
                      width: 100.0,
                      height: 100.0,
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
                        '1. ร้านจาคอฟฟี',
                        style: TextStyle(fontSize: 18),
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
  runApp(MaterialApp(
    home: Scaffold(
      body: SlidePlace(),
    ),
  ));
}
