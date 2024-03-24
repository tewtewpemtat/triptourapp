import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MaterialApp(
      home: SlideTime(), // นำ MyApp() ไปเป็นหน้าจอหลัก
    ),
  );
}

class SlideTime extends StatefulWidget {
  final String? selectedPlaceUid; // รับค่า UID จาก SlidePlace widget

  const SlideTime({Key? key, this.selectedPlaceUid}) : super(key: key);

  @override
  _SlideTimeState createState() => _SlideTimeState();
}

class _SlideTimeState extends State<SlideTime> {
  List<String> availableDays = ['24', '25', '26'];
  String? selectedDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(0.0),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เลือกเวลาเริ่มต้น-สิ้นสุด',
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                hint: Text('วันที่'),
                value: selectedDay,
                items: availableDays.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedDay = value;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10), // เพิ่มระยะห่างระหว่าง DropdownButton และ Text
          Text(
            'UID ของสถานที่: ${widget.selectedPlaceUid ?? "ไม่พบ"}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
