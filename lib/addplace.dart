import 'package:flutter/material.dart';
import 'addplace/downplace.dart';
import 'addplace/slideplace.dart';

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Expanded(
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Container(
              height: 45.0, // กำหนดความสูงตรงนี้
              width: double.infinity, // กำหนดความกว้างตรงนี้
              child: TextField(
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  hintText: 'ค้นหาประวัติทริป',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled:
                      true, // ตั้งค่าเป็น true เพื่อเปิดใช้งานการเติมสีพื้นหลัง
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'เพิ่มสถานที่',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'เพิ่มสถานที่บนทริปของคุณ',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: SlidePlace(),
          ),
          Expanded(
            child: DownPage(),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddPage(),
  ));
}
