import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlidePlace extends StatefulWidget {
  @override
  final String? tripUid;
  final ValueChanged<String>?
      onPlaceTypeChanged; // เพิ่ม callback function เพื่อส่งค่า placeType ไปยัง DownPage

  const SlidePlace({Key? key, this.tripUid, this.onPlaceTypeChanged})
      : super(key: key);
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
      height: 120,
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
            style: GoogleFonts.ibmPlexSansThai(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
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
          if (widget.onPlaceTypeChanged != null) {
            // เรียกใช้ Callback function เมื่อมีการเลือก placeType
            widget.onPlaceTypeChanged!(placeType);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(9.0),
        margin: EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
          color: isSelected ? Color(0xFFECB800) : Colors.white,
        ),
        child: Text(
          placeType,
          style: GoogleFonts.ibmPlexSansThai(
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
