import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SlidePlace extends StatefulWidget {
  @override
  final String? tripUid;
  final ValueChanged<Map<String, String>>? onPlaceTypeChanged;
  // เพิ่ม callback function เพื่อส่งค่า placeType และ selectedOption ไปยัง DownPage

  const SlidePlace({Key? key, this.tripUid, this.onPlaceTypeChanged})
      : super(key: key);
  _SlidePlaceState createState() => _SlidePlaceState();
}

class _SlidePlaceState extends State<SlidePlace> {
  List<String> placeTypes = [
    'ร้านกาแฟ',
    'ธรรมชาติ',
    'สวนสนุก',
    'อาหาร',
    'สตรีทฟู้ด',
    'วัดโบสถ์',
    'กำหนดเอง'
  ];

  String selectedPlaceType = 'ร้านกาแฟ';
  String selectedOption = 'จากตำแหน่งใกล้ฉัน';

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
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // จัดการวางจากขวาไปซ้าย
            children: [
              Text(
                'ประเภทสถานที่',
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  width: 10), // เพิ่มระยะห่างระหว่าง DropdownButton กับข้อความ
              DropdownButton<String>(
                value: selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue ??
                        ''; // ถ้าค่าเป็น null ให้เปลี่ยนเป็น string ว่าง
                    _sendDataToDownPage(); // เรียกใช้ฟังก์ชันส่งข้อมูลไปยัง DownPage
                  });
                },
                items: <String>[
                  'จากตำแหน่งใกล้ฉัน',
                  'จากตำแหน่งบนแผนที่',
                  'จากคำขอแนะนำสถานที่',
                  'เพิ่มสถานที่เอง'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 5),
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
          _sendDataToDownPage(); // เรียกใช้ฟังก์ชันส่งข้อมูลไปยัง DownPage
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

  void _sendDataToDownPage() {
    if (widget.onPlaceTypeChanged != null) {
      // เรียก callback function เพื่อส่งค่า placeType และ selectedOption ไปยัง DownPage
      widget.onPlaceTypeChanged!({
        'placeType': selectedPlaceType,
        'selectedOption': selectedOption,
      });
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: SlidePlace(),
    ),
  ));
}
