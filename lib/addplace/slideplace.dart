import 'package:flutter/material.dart';

class SlidePlace extends StatefulWidget {
  @override
  _SlidePlaceState createState() => _SlidePlaceState();
}

class _SlidePlaceState extends State<SlidePlace> {
  List<String> placeTypes = [
    'ร้านกาแฟ',
    'ทะเล',
    'ธรรมชาติ',
    'สวนสนุก',
    'อาหาร',
    'ร้านสตรีทฟู้ด',
    'วัดโบส',
    'ภูเขา',
  ];

  String selectedPlaceType = 'ร้านกาแฟ';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(0.0),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 6,
            offset: Offset(0, 3), // เปลี่ยนตำแหน่งของเงาลงไปทางล่าง
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ประเภทสถานที่',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: placeTypes.map((type) {
                return _buildPlaceType(type);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceType(String placeType) {
    bool isSelected = selectedPlaceType == placeType;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlaceType = placeType;
        });
      },
      child: Container(
        padding: EdgeInsets.all(9.0),
        margin: EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(5.0),
          color: isSelected ? Color(0xFFECB800) : Colors.white,
        ),
        child: Text(
          placeType,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold, // เพิ่มบรรทัดนี้เพื่อทำให้ตัวหนา
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
