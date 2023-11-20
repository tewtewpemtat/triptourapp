import 'package:flutter/material.dart';

class HeadInfoButton extends StatefulWidget {
  @override
  _HeadInfoButtonState createState() => _HeadInfoButtonState();
}

class _HeadInfoButtonState extends State<HeadInfoButton> {
  bool showMapBlock = false;
  bool showMapThing = false;

  @override
  void initState() {
    super.initState();
    showMapBlock = false;
    showMapThing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                      Text('ตำแหน่งผู้ร่วมทริป'),
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
                      SizedBox(width: 8),
                      Text('สถานที่น่าสนใจ'),
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
                      Text('สิ่งน่าสนใจ'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              SizedBox(width: 10),
              Text(
                'สมาชิกที่เข้าร่วม',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
