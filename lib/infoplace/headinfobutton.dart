import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math' show sin, cos, sqrt, pow, atan2, pi;

class HeadInfoButton extends StatefulWidget {
  @override
  final String? tripUid;
  final String? placeid;
  const HeadInfoButton({Key? key, this.tripUid, this.placeid})
      : super(key: key);

  HeadInfoButtonState createState() => HeadInfoButtonState();
}

class HeadInfoButtonState extends State<HeadInfoButton> {
  bool showMapBlock = false;
  bool showMapThing = false;
  String? saveTimelineOption;
  double? distance;
  double? distance2;

  @override
  void initState() {
    super.initState();
    showMapBlock = false;
    showMapThing = false;
    saveTimelineOption = 'ไม่บันทึก';
  }

  double calculateDistance(double distance) {
    double distanceInMeters = distance / 1000;
    return distanceInMeters;
  }

  // เปลี่ยนจากองศาเป็นเรเดียน

  void changeDistace() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ระยะในการบันทึก (เมตร)'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'ระยะในการบันทึก (เมตร)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            double doubleValue = double.tryParse(value) ?? 0.0;
            print(doubleValue);
            distance2 = doubleValue;
            // แปลงเป็นข้อความ
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // เมื่อผู้ใช้ป้อนระยะห่างในการค้นหาแล้วให้ดึงสถานที่ใกล้เคียงตามระยะที่ระบุ
              setState(() {
                distance = calculateDistance(distance2 ?? 0.0);
                // แปลงเป็นข้อความ
              });
              Fluttertoast.showToast(
                msg: "บันทึกระยะสำเร็จ",
                toastLength: Toast.LENGTH_LONG,
              );
            },
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void deleteDistace() async {
    setState(() {
      distance = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                "ตัวเลือกการบันทึกไทมไลน์  : ",
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: saveTimelineOption,
                onChanged: (String? newValue) {
                  setState(() {
                    saveTimelineOption = newValue;
                  });
                  if (saveTimelineOption == 'บันทึก') {
                    changeDistace();
                  }
                  if (saveTimelineOption == 'ไม่บันทึก') {
                    deleteDistace();
                  }
                },
                items: <String>['บันทึก', 'ไม่บันทึก'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(width: 20),
              Text(
                "$distance",
                style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showMapBlock = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // สีพื้นหลังของปุ่ม
                    onPrimary: Colors.black, // สีขอบตัวอักษร
                    fixedSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.place),
                      SizedBox(width: 8),
                      Text('ตำแหน่งผู้ร่วมทริป',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: showMapBlock,
                child: Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 300,
                        color: Colors.grey,
                        child: Center(
                          child: Text(
                            'This is the map block',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showMapBlock = false;
                            });
                          },
                          child: Icon(
                            Icons.remove, // แทนด้วย icon ที่คุณต้องการ
                            color: Colors.red, // สีของ icon
                            size: 30, // ขนาดของ icon
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showMapThing = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // สีพื้นหลังของปุ่ม
                    onPrimary: Colors.black, // สีขอบตัวอักษร
                    fixedSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map),
                      SizedBox(width: 5),
                      Text('จุดนัดพบบนแผนที่',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showMapThing = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // สีพื้นหลังของปุ่ม
                    onPrimary: Colors.black, // สีขอบตัวอักษร
                    fixedSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star),
                      SizedBox(width: 8),
                      Text('สิ่งน่าสนใจ',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: showMapThing,
                child: Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 300,
                        color: Colors.grey,
                        child: Center(
                          child: Text(
                            'This is the map block',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showMapThing = false;
                            });
                          },
                          child: Icon(
                            Icons.remove, // แทนด้วย icon ที่คุณต้องการ
                            color: Colors.red, // สีของ icon
                            size: 30, // ขนาดของ icon
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: HeadInfoButton(),
    ),
  );
}
