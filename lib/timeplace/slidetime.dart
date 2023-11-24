import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: SlideTime(),
    ),
  );
}

class SlideTime extends StatefulWidget {
  @override
  _SlideTimeState createState() => _SlideTimeState();
}

class _SlideTimeState extends State<SlideTime> {
  List<String> placeTypes = [
    '01:00',
    '01:30',
    '02:00',
    '02:30',
    '03:00',
    '03:30',
    '04:00',
    '04:30',
    '05:00',
    '05:30',
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
  ];

  List<String> selectedPlaceTypes = [];
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
                style: TextStyle(
                  fontSize: 16.0,
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
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: placeTypes.map((type) {
                return _buildPlaceType(type);
              }).toList(),
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              // Save the selected time slots
              print('Selected Time Slots: $selectedPlaceTypes');
              setState(() {
                // Perform any other action you want after saving
                selectedPlaceTypes
                    .clear(); // Clear the selectedPlaceTypes list after saving
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              primary: Colors.white,
            ),
            child: Text(
              'บันทึก',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceType(String timeType) {
    bool isSelected = selectedPlaceTypes.contains(timeType);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedPlaceTypes.remove(timeType);
          } else {
            selectedPlaceTypes.add(timeType);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(9.0),
        margin: EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
          color: isSelected ? Colors.yellow : Colors.white,
        ),
        child: Text(
          timeType,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
